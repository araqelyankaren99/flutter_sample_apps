#ifndef NativeOpenCv_h
#define NativeOpenCv_h

#include <stdint.h>
#include <stddef.h>
#include <sys/types.h>

#ifdef __cplusplus
extern "C" {
#endif

void process_image(char* inputImagePath, char* outputImagePath);
struct DetectionResult* detect_document_edges(char* inputImagePath, char* outputImagePath);
struct DetectionResult* detect_document_edges_ex(
        int32_t width,
        int32_t height,
        int32_t bytesPerPixel,
        u_char *imgBytes,
        char* outputImagePath);

#ifdef __cplusplus
}
#endif

#endif
