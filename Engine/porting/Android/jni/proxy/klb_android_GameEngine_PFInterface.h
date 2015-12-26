/* DO NOT EDIT THIS FILE - it is machine generated */
#include <jni.h>
/* Header for class klb_android_GameEngine_PFInterface */
#include "../Android/PackageDefine.h"


#ifndef _Included_klb_android_GameEngine_PFInterface
#define _Included_klb_android_GameEngine_PFInterface
#ifdef __cplusplus
extern "C" {
#endif
/*
 * Class:     klb_android_GameEngine_PFInterface
 * Method:    initSequence
 * Signature: (IILjava/lang/String;)Z
 */
JNIEXPORT jboolean JNICALL JAVA_FUNC(initSequence)
  (JNIEnv *, jobject, jint, jint, jstring, jstring, jstring, jstring, jstring, jstring);

/*
 * Class:     klb_android_GameEngine_PFInterface
 * Method:    frameFlip
 * Signature: (I)V
 */
JNIEXPORT void JNICALL JAVA_FUNC(frameFlip)
  (JNIEnv *, jobject, jint);

/*
 * Class:     klb_android_GameEngine_PFInterface
 * Method:    finishGame
 * Signature: ()V
 */
JNIEXPORT void JNICALL JAVA_FUNC(finishGame)
  (JNIEnv *, jobject);

/*
 * Class:     klb_android_GameEngine_PFInterface
 * Method:    inputPoint
 * Signature: (IIII)V
 */
JNIEXPORT void JNICALL JAVA_FUNC(inputPoint)
  (JNIEnv *, jobject, jint, jint, jint, jint);

/*
 * Class:     klb_android_GameEngine_PFInterface
 * Method:    inputDeviceKey
 * Signature: (IC)V
 */
JNIEXPORT void JNICALL JAVA_FUNC(inputDeviceKey)
  (JNIEnv *, jobject, jint, jchar);

/*
 * Class:     klb_android_GameEngine_PFInterface
 * Method:    rotateScreenOrientation
 * Signature: (III)V
 */
JNIEXPORT void JNICALL JAVA_FUNC(rotateScreenOrientation)
  (JNIEnv *, jobject, jint, jint, jint);

/*
 * Class:     klb_android_GameEngine_PFInterface
 * Method:    toNativeSignal
 * Signature: (II)V
 */
JNIEXPORT void JNICALL JAVA_FUNC(toNativeSignal)
  (JNIEnv *, jobject, jint, jint);

JNIEXPORT jint JNICALL JAVA_FUNC(getGLVersion)
  (JNIEnv *, jobject);

/*
 * Class:     klb_android_GameEngine_PFInterface
 * Method:    resetViewport
 * Signature: ()V
 */
JNIEXPORT void JNICALL JAVA_FUNC(resetViewport)
  (JNIEnv *, jobject);

/*
 * Class:     klb_android_GameEngine_PFInterface
 * Method:    onActivityPause
 * Signature: ()V
 */
JNIEXPORT void JNICALL JAVA_FUNC(onActivityPause) ( void );

/*
 * Class:     klb_android_GameEngine_PFInterface
 * Method:    onActivityResume
 * Signature: ()V
 */
JNIEXPORT void JNICALL JAVA_FUNC(onActivityResume) ( void );

/*
 * Class:     klb_android_GameEngine_PFInterface
 * Method:    WebViewControlEvent
 * Signature: ()V
 */
JNIEXPORT void JNICALL JAVA_FUNC(WebViewControlEvent) ( JNIEnv *, jobject, jobject, jint );

/*
 * Class:     klb_android_GameEngine_PFInterface
 * Method:    clientResumeGame
 * Signature: ()V
 */
JNIEXPORT void JNICALL JAVA_FUNC(clientResumeGame) ( void );

JNIEXPORT void JNICALL JAVA_FUNC(jniOnLoad) ( JavaVM*, void* );

#ifdef __cplusplus
}
#endif
#endif
