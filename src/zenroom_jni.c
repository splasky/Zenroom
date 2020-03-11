#include "zenroom_jni.h"
#include "zenroom.h"

#ifdef ARCH_ANDROID
#include <android/log.h>
#endif

JNIEXPORT jstring JNICALL Java_decode_zenroom_Zenroom_zenroom
  (JNIEnv *env, jobject obj, jstring jni_script, jstring jni_conf, jstring jni_keys, jstring jni_data) {

    jstring result;
    char* script = (*env)->GetStringUTFChars(env, jni_script, 0);
    char* conf = (*env)->GetStringUTFChars(env, jni_conf, 0);
    char* keys = (*env)->GetStringUTFChars(env, jni_keys, 0);
    char* data = (*env)->GetStringUTFChars(env, jni_data, 0);


    size_t outputSize = 1024 * 128;
    char *z_output = (char*)malloc(outputSize * sizeof(char));
    size_t  errorSize = 1024 * 128;
    char *z_error = (char*)malloc(errorSize * sizeof(char));

    int ret = zencode_exec_tobuf(script, conf, keys, data, z_output, outputSize, z_error, errorSize);

#ifdef __ANDROID__
// __android_log_print(ANDROID_LOG_VERBOSE, "Zenroom", "len %i", strlen(z_output));
// __android_log_print(ANDROID_LOG_VERBOSE, "Zenroom", "output %s", z_output);
// __android_log_print(ANDROID_LOG_WARN, "Zenroom", "len %i", strlen(z_error));

__android_log_print(ANDROID_LOG_WARN,    "Zenroom/stderr", "%s", z_error);
__android_log_print(ANDROID_LOG_VERBOSE, "Zenroom/stdout", "%s", z_output);

#endif

    free(z_error);
    (*env)->ReleaseStringUTFChars(env, jni_script, script);
    (*env)->ReleaseStringUTFChars(env, jni_conf, conf);
    (*env)->ReleaseStringUTFChars(env, jni_keys, keys);
    (*env)->ReleaseStringUTFChars(env, jni_data, data);

    result = (*env)->NewStringUTF(env, z_output);
    free(z_output);

    return result;
}
