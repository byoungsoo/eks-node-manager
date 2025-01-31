import boto3
import os
import datetime

ec2Client = boto3.client('ec2')
asgClient = boto3.client('autoscaling')
ssmClient = boto3.client('ssm')
eks_client = boto3.client('eks')


def get_current_ami(asg_name):
    asg_detail_res = asgClient.describe_auto_scaling_groups(
        AutoScalingGroupNames=[
            asg_name
        ]
    )
    lt_id = \
    asg_detail_res['AutoScalingGroups'][0]['MixedInstancesPolicy']['LaunchTemplate']['LaunchTemplateSpecification'][
        'LaunchTemplateId']
    lt_version = \
    asg_detail_res['AutoScalingGroups'][0]['MixedInstancesPolicy']['LaunchTemplate']['LaunchTemplateSpecification'][
        'Version']

    lt_detail_res = ec2Client.describe_launch_template_versions(
        LaunchTemplateId=lt_id,
        Versions=[
            lt_version
        ]
    )
    current_ami_id = lt_detail_res['LaunchTemplateVersions'][0]['LaunchTemplateData']['ImageId']
    return current_ami_id


def get_latest_ami(eksClusterVersion, amiType):
    name = ""
    if amiType == "AL2_x86_64":
        name = "/aws/service/eks/optimized-ami/" + eksClusterVersion + "/amazon-linux-2/recommended/image_id"
    elif amiType == "AL2_x86_64_GPU":
        name = "/aws/service/eks/optimized-ami/" + eksClusterVersion + "/amazon-linux-2-gpu/recommended/image_id"
    elif amiType == "AL2_ARM_64":
        name = "/aws/service/eks/optimized-ami" + eksClusterVersion + "/amazon-linux-2-arm64/recommended/image_id"
    elif amiType == "BOTTLEROCKET_x86_64":
        name = "/aws/service/bottlerocket/aws-k8s-" + eksClusterVersion + "/x86_64/latest/image_id"
    elif amiType == "BOTTLEROCKET_ARM_64":
        name = "/aws/service/bottlerocket/aws-k8s-" + eksClusterVersion + "/arm64/latest/image_id"
    elif amiType == "BOTTLEROCKET_x86_64_NVIDIA":
        name = "/aws/service/bottlerocket/aws-k8s-" + eksClusterVersion + "-nvidia/arm64/latest/image_id"
    elif amiType == "BOTTLEROCKET_ARM_64_NVIDIA":
        name = "/aws/service/bottlerocket/aws-k8s-" + eksClusterVersion + "-nvidia/arm64/latest/image_id"
    elif amiType == "AL2023_x86_64_STANDARD":
        name = "/aws/service/eks/optimized-ami/" + eksClusterVersion + "/amazon-linux-2023/x86_64/standard/recommended/image_id"
    elif amiType == "AL2023_ARM_64_STANDARD":
        name = "/aws/service/eks/optimized-ami/" + eksClusterVersion + "/amazon-linux-2023/arm64/standard/recommended/image_id"
    elif amiType == "WINDOWS_CORE_2019_x86_64":
        name = "/aws/service/ami-windows-latest/Windows_Server-2019-English-Core-EKS_Optimized-" + eksClusterVersion + "/image_id"
    elif amiType == "WINDOWS_FULL_2019_x86_64":
        name = "/aws/service/ami-windows-latest/Windows_Server-2019-English-Full-EKS_Optimized-" + eksClusterVersion + "/image_id"
    elif amiType == "WINDOWS_CORE_2022_x86_64":
        name = "/aws/service/ami-windows-latest/Windows_Server-2022-English-Core-EKS_Optimized-" + eksClusterVersion + "/image_id"
    elif amiType == "WINDOWS_FULL_2022_x86_64":
        name = "/aws/service/ami-windows-latest/Windows_Server-2022-English-Full-EKS_Optimized-" + eksClusterVersion + "/image_id"

    latest_ami_res = ssmClient.get_parameter(
        Name=name
    )
    # print("LatestAMI: ", latest_ami_res['Parameter']['Name'])

    # Value: ami-02ce95f7f23d880fc
    return latest_ami_res['Parameter']['Value']


def need_update(current_ami_id, latest_ami_id):
    if current_ami_id != latest_ami_id:
        return True
    else:
        return False


def update_mng_nodegroup():
    eks_clusters_res = eks_client.list_clusters()
    eks_clusters = eks_clusters_res['clusters']
    exclude_eks_cluster = os.environ['ExcludeEKSClusters']
    
    target_eks_clusters = [cluster for cluster in eks_clusters if cluster not in exclude_eks_cluster]
    for eks_cluster in target_eks_clusters:
        eks_cluster_details_res = eks_client.describe_cluster(
            name=eks_cluster
        )

        # eks_cluster_version: 1.28
        eks_cluster_version = eks_cluster_details_res['cluster']['version']

        node_group_res = eks_client.list_nodegroups(
            clusterName=eks_cluster
        )
        node_groups = node_group_res['nodegroups']

        # Create JsonData for result

        for node_group in node_groups:
            node_group_details_res = eks_client.describe_nodegroup(
                clusterName=eks_cluster,
                nodegroupName=node_group
            )
            ng_status = node_group_details_res['nodegroup']['status']

            if ng_status == "CREATE_FAILED":
                eks_client.delete_nodegroup(
                    clusterName=eks_cluster,
                    nodegroupName=node_group
                )

            if ng_status != "ACTIVE":
                continue

            # amiType:
            # CUSTOM, AL2_x86_64, AL2_x86_64_GPU, AL2_ARM_64,
            # BOTTLEROCKET_ARM_64, BOTTLEROCKET_x86_64, BOTTLEROCKET_ARM_64_NVIDIA, BOTTLEROCKET_x86_64_NVIDIA,
            # WINDOWS_CORE_2019_x86_64, WINDOWS_FULL_2019_x86_64, WINDOWS_CORE_2022_x86_64, WINDOWS_FULL_2022_x86_64
            ami_type = node_group_details_res['nodegroup']['amiType']

            if ami_type != "CUSTOM":
                asg_name = node_group_details_res['nodegroup']['resources']['autoScalingGroups'][0]['name']

                latest_ami_id = get_latest_ami(eks_cluster_version, ami_type)
                current_ami_id = get_current_ami(asg_name)
                need_update_flag = need_update(current_ami_id, latest_ami_id)

                if need_update_flag:
                    try:
                        print("Update nodegroup version: ", eks_cluster, "-", node_group)
                        eks_client.update_nodegroup_version(
                            clusterName=eks_cluster,
                            nodegroupName=node_group
                        )
                    except Exception as e:
                        print("Failed: ", eks_cluster, "-", node_group)
                        print(e)
                else:
                    print("Skip cause of latest: ", eks_cluster, "-", node_group)


if __name__ == '__main__':
    now = datetime.datetime.now()
    formatted_date = now.strftime("%Y-%m-%d %H:%M:%S")

    print("Date:", formatted_date)
    update_mng_nodegroup()