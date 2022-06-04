REGION = us-west-2
BUILD_DIR := ./aws/${REGION}/dev/
 

.PHONY = all clean


rollout: 
	@echo "This will run second, because it depends on other_file"
	ls ${BUILD_DIR}

destroy:
	echo "This will run first"
	touch other_file