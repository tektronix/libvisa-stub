cmake_minimum_required( VERSION 3.9 )

project( 
	visa
	VERSION 0.0.0 
	DESCRIPTION "A stub library to build VISA applications against, no license required."
)

add_library( 
	${PROJECT_NAME}
	SHARED
	./stub.c
)

set_target_properties(
	${PROJECT_NAME}
	PROPERTIES
	VERSION ${PROJECT_VERSION}
)

set_target_properties(
	${PROJECT_NAME} 
	PROPERTIES
	PUBLIC_HEADER 
	./visa.h 
)

set_target_properties(
	${PROJECT_NAME} 
	PROPERTIES
	PUBLIC_HEADER 
	./visatypes.h
)
