file(GLOB SOURCES
	"*.h"
	"*.cpp"
)

target_sources(gmsv-curl PRIVATE ${SOURCES})
