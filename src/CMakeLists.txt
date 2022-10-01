file(GLOB SOURCES
	"*.h"
	"*.cpp"
)

target_sources(gmcurl PRIVATE ${SOURCES})
