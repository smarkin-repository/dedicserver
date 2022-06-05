REGION = us-west-2
BUILD_DIR := ./aws/${REGION}/dev/
 

.PHONY = all clean


rollout: 
	@echo "This will run second, because it depends on other_file"
	ls ${BUILD_DIR}

all-resources:
	aws resourcegroupstaggingapi get-resources --tag-filters Key=Stack,Values=xonotic --query "ResourceTagMappingList[].ResourceARN" --output json

destroy:
	echo "This will run first"
	touch other_file