
#ifndef __COCOS2D_X_EXTRA_H_
#define __COCOS2D_X_EXTRA_H_

#include "cocos2d.h"
#include <string>

using namespace std;
using namespace cocos2d;

#ifndef CC_LUA_ENGINE_ENABLED
#define CC_LUA_ENGINE_ENABLED 1
#endif

#ifndef NS_CC_EXTRA_BEGIN
#define NS_CC_EXTRA_BEGIN namespace cocos2d { namespace extra {
#endif

#ifndef NS_CC_EXTRA_END
#define NS_CC_EXTRA_END   }}
#endif

#ifndef USING_NS_CC_EXTRA
#define USING_NS_CC_EXTRA using namespace cocos2d::extra
#endif

#endif /* __COCOS2D_X_EXTRA_H_ */
