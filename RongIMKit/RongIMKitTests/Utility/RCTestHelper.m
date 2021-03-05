//
//  RCTestHelper.m
//  RongIMKitTests
//
//  Created by 杜立召 on 2020/2/21.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "RCTestHelper.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation RCTestHelper

+ (RCTextMessage *)getTextMessage {
    RCTextMessage *textMessage = [RCTextMessage messageWithContent:@"test"];
    return textMessage;
}

+ (RCImageMessage *)getImageMessage {
    NSData *imageData = nil;
    NSString *imageBaseString =
        @"/9j/4AAQSkZJRgABAQAAAQABAAD/"
        @"2wBDABALDA4MChAODQ4SERATGCgaGBYWGDEjJR0oOjM9PDkzODdASFxOQERXRTc4UG1RV19iZ2hnPk1xeXBkeFxlZ2P/"
        @"2wBDARESEhgVGC8aGi9jQjhCY2NjY2NjY2NjY2NjY2NjY2NjY2NjY2NjY2NjY2NjY2NjY2NjY2NjY2NjY2NjY2NjY2P/"
        @"wAARCABkAPADASIAAhEBAxEB/8QAGgABAQEBAQEBAAAAAAAAAAAAAAECBQMEBv/"
        @"EACsQAAIBAwMEAgICAgMAAAAAAAABAgMRElJhkQQhMaFRcQVBEyIUMiNigf/EABQBAQAAAAAAAAAAAAAAAAAAAAD/"
        @"xAAUEQEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIRAxEAPwD94AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAI/"
        @"K+ykflfZ5dYnLo68YpuTpySS8vsB7A4cOnq9LNuj0yoXox79PT/AN/7LK//AGSvb7ZXPr5Tq4vqFThSqypf0s5NOON+3n/"
        @"bt+"
        @"0B2wawjpXAwjpXAGQawjpXAwjpXAGQawjpXAwjpXAGQawjpXAwjpXAGQawjpXAwjpXAGQawjpXAwjpXAGQawjpXAwjpXAGQawjpXAwjpXAGQ"
        @"awjpXAwjpXAGQawjpXAwjpXAGQawjpXAwjpXAGQawjpXAwjpXAGQawjpXAwjpXAGH5X2UrhG6/"
        @"qvPwXCOlcAZBrCOlcDCOlcAaAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAGX5X2efVylDo684u0o05NP4dj0flfZWrqz7oDiQ62tSm+"
        @"1Wm1Rg2uokmpOUkslZ+F3v3+Cy/KdX/JVhH+C1GnVnKWDtPBx8d+3lr990dlwi/MU+1u6/"
        @"RFTglZQila1rfr4Azbd8sW3fLKAJbd8sW3fLKAJbd8sW3fLKAJbd8sW3fLKAJbd8sW3fLKAJbd8sW3fLKAJbd8sW3fLKAJbd8sW3fLKAJbd8"
        @"sW3fLKAJbd8sW3fLKAJbd8sW3fLKAJbd8sW3fLKAJbd8sW3fLKAMtd13fn5Zbbvlh+"
        @"V9mOpqOl01WpGzcIOSvsgN23fLFt3yzlUfylV5OSjVxhFtKlKljKTSiv7N3Tv5/VjUvy84znT/"
        @"wAZOdKM5Vf+TtFRte3bv2kn+"
        @"gOoC4PV6GD1egIC4PV6GD1egIC4PV6GD1egIC4PV6GD1egIC4PV6GD1egIC4PV6GD1egIC4PV6GD1egIC4PV6GD1egIC4PV6GD1egIC4PV6G"
        @"D1egIC4PV6GD1egIC4PV6GD1egIC4PV6GD1egMvyvsk4RqQlCavGSs18o04O67/ALLg9XoD56nRdPVac6d2oYXTa7fHr/"
        @"wzHoOljFpUvMJQbcm21Lzd373t58n1YPV6GD1egNgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADL8r7M16n8NCpVtfCLlb5sjT8r7JVpqrSn"
        @"TldKcXF23A+Gl+Td7dRTpxTpqadKp/J+0rPsrO7Vvnubf5XpoyxbnklKUlg7xUWr3+PKK/"
        @"xdC7cHOnlGMZYWSeLvFvt5RlfiqGVWTnVc6sJwnJtXeVrvx57ID7wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABl+V9mgAAAA//Z";

    if (class_getInstanceMethod([NSData class], @selector(initWithBase64EncodedString:options:))) {
        imageData = [[NSData alloc] initWithBase64EncodedString:imageBaseString
                                                        options:NSDataBase64DecodingIgnoreUnknownCharacters];
    } else {
        imageData = [RCUtilities dataWithBase64EncodedString:imageBaseString];
    }
    UIImage *testImage = [UIImage imageWithData:imageData];

    RCImageMessage *imageMessage = [RCImageMessage messageWithImage:testImage];
    return imageMessage;
}

+ (RCFileMessage *)getFileMessage {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0]
        stringByAppendingPathComponent:@"MyFile"];
    documentPath = [documentPath stringByAppendingPathComponent:@"emoji_1.png"];
    RCFileMessage *fileMessage = [RCFileMessage messageWithFile:documentPath];
    return fileMessage;
}

+ (RCSightMessage *)getSightMessage {
    //    NSURL *imageUrl = [[NSBundle bundleForClass:[self class]] URLForResource:IMAGENAME withExtension:@"png"];
    //    UIImage *testImage = [UIImage imageWithData:[NSData
    //                                                 dataWithContentsOfURL:[NSURL URLWithString:[imageUrl
    //                                                 absoluteString]]]];
    //    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:VIDEONAME withExtension:@"mp4"];
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0]
        stringByAppendingPathComponent:@"test"];
    NSString *wavFileName = [documentPath stringByAppendingPathComponent:@"wavDec.wav"];
    NSString *imagePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0]
        stringByAppendingPathComponent:@"MyFile"];
    imagePath = [imagePath stringByAppendingPathComponent:@"emoji_1.png"];
    UIImage *testImage = [UIImage imageWithContentsOfFile:imagePath];
    RCSightMessage *sightMessage = [RCSightMessage messageWithLocalPath:wavFileName thumbnail:testImage duration:6];
    return sightMessage;
}

+(RCGIFMessage *)getGifMessage{
    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"rock" withExtension:@"gif"];
    RCGIFMessage *gif = [RCGIFMessage messageWithGIFURI:[url absoluteString] width:100 height:100];
    return gif;
}

+ (NSDictionary *)getAllRongCloudClasses {
    NSMutableDictionary *dic = [NSMutableDictionary new];
    NSMutableArray *vcClassNameArray = [NSMutableArray new];
    NSMutableArray *cellClassNameArray = [NSMutableArray new];
    int classCount = objc_getClassList(NULL, 0);
    Class *classes = NULL;
    classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * classCount);
    classCount = objc_getClassList(classes, classCount);

    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    dispatch_apply(classCount, dispatch_get_global_queue(0, 0), ^(size_t index) {
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        Class class = classes[index];
        NSString *className = [[NSString alloc] initWithUTF8String:class_getName(class)];
        if ([className hasPrefix:@"RC"] && [className hasSuffix:@"Controller"] &&
            ![className isEqualToString:@"RCPhotoPreviewCollectionViewController"] &&
            ![className isEqualToString:@"RCPhotosPickerController"] &&
            ![className isEqualToString:@"RCPublicServiceWebViewController"] &&
            ![className isEqualToString:@"RCUserListViewController"]) {
            [vcClassNameArray addObject:className];
        }
        if ([className hasPrefix:@"RC"] && [className hasSuffix:@"Cell"]) {
            [cellClassNameArray addObject:className];
        }
        NSLog(@"%@", className);
        dispatch_semaphore_signal(semaphore);
    });

    [dic setValue:cellClassNameArray forKey:@"Cell"];
    [dic setValue:vcClassNameArray forKey:@"ViewController"];
    free(classes);
    return dic.mutableCopy;
}

+ (NSArray<RCMethodModel *> *)getAllInstanceMethods:(Class)cla except:(NSDictionary *)exceptMethods{
    unsigned int methodCount = 0;
    Method *methodList = class_copyMethodList(cla, &methodCount);
    NSMutableArray *methodArray = [NSMutableArray arrayWithCapacity:methodCount];
    unsigned int  propertyCount;
    objc_property_t*    properties= class_copyPropertyList(cla, &propertyCount);
    NSMutableDictionary *propertyDic = [NSMutableDictionary dictionaryWithCapacity:propertyCount];
    for (int i = 0; i < propertyCount ; i++){
        const char* propertyName = property_getName(properties[i]);
        NSString *strName = [NSString  stringWithCString:propertyName encoding:NSUTF8StringEncoding];
        [propertyDic setValue:strName forKey:[strName lowercaseString]];
    }
    
    for (int i = 0; i < methodCount; i++) {

        Method temp = methodList[i];
        SEL name_F = method_getName(temp);
        const char *name_s = sel_getName(name_F);
        int arguments = method_getNumberOfArguments(temp);
        const char *encoding = method_getTypeEncoding(temp);
        if (encoding && encoding == NULL) {
            continue;
        }
        if (name_s && name_s == NULL) {
            continue;
        }
        NSString *methodName = [NSString stringWithUTF8String:name_s];
        if ([methodName isEqualToString:@"dealloc"] || [methodName isEqualToString:@"initWithView:"] || [methodName isEqualToString:@"scrollViewDidZoom:"] || [methodName isEqualToString:@"frameToPositionInRelationWith"]||[methodName isEqualToString:@"showAlertController:message:cancelTitle:"]||[methodName isEqualToString:@"strechToSuperview:"]) {
            continue;
        }
        if ([methodName hasPrefix:@"set"]) {
            NSString *subStr = [methodName substringWithRange:NSMakeRange(3, [methodName length] - 4)];
            if([propertyDic objectForKey:[subStr lowercaseString]]){
                continue;
            }
        }
        
        if (exceptMethods && exceptMethods[methodName]) {
            continue;
        }
        NSLog(@"ClassName: %@ MethodName: %@,ArgumentCount: %d,RCMethodType: %lu", [cla class], methodName, arguments,
              RCMethodType_InstanceMethod);
        RCMethodModel *model = [[RCMethodModel alloc] init];
        model.methodName = methodName;
        model.argumentCount = arguments;
        model.methodType = RCMethodType_InstanceMethod;
        [methodArray addObject:model];
    }

    free(methodList);
    return methodArray;
}

+ (NSArray<RCMethodModel *> *)getAllClassMethods:(Class)cla except:(NSDictionary *)exceptMethods{
    Class metaClass = object_getClass([cla class]);
    unsigned int count;
    Method *classMethods = class_copyMethodList(metaClass, &count);
    NSMutableArray *methodArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count; i++) {
        Method classMethod = classMethods[i];
        SEL selector = method_getName(classMethod);
        NSString *name = NSStringFromSelector(selector);
        int arguments = method_getNumberOfArguments(classMethod);
        RCMethodModel *model = [[RCMethodModel alloc] init];
        model.methodName = name;
        model.argumentCount = arguments;
        model.methodType = RCMethodType_ClassMethod;
        NSLog(@"ClassName: %@ MethodName: %@,ArgumentCount: %d,RCMethodType:%lu", [cla class], name, arguments,(unsigned long)RCMethodType_ClassMethod);
        if ([name isEqualToString:@"getWindowSafeAreaInsets"]) {
            continue;
        }
        if (exceptMethods && exceptMethods[name]) {
            continue;
        }
        [methodArray addObject:model];
    }
    free(classMethods);
    return methodArray;
}


+ (void)excuteInstanceMethod:(NSObject * _Nonnull)instance methodList:(NSArray<RCMethodModel *> *)methodList {
    for (RCMethodModel *method in methodList) {
        SEL selector = NSSelectorFromString(method.methodName);
        if ([instance respondsToSelector:selector]) {
            NSLog(@"ClassName: %@ MethodName: %@,ArgumentCount: %d,RCMethodType:%lu --- Begin", [instance class], method.methodName,
                  method.argumentCount,method.methodType);
            if (method.argumentCount == 2) {
                IMP imp = [instance methodForSelector:selector];
                void (*func)(id, SEL) = (void *)imp;
                func(instance, selector);
            }
            if (method.argumentCount == 3) {
                IMP imp = [instance methodForSelector:selector];
                void (*func)(id, SEL, id) = (void *)imp;
                func(instance, selector, nil);
            }
            if (method.argumentCount == 4) {
                IMP imp = [instance methodForSelector:selector];
                void (*func)(id, SEL, id, id) = (void *)imp;
                func(instance, selector, nil, nil);
            }
            if (method.argumentCount == 5) {
                IMP imp = [instance methodForSelector:selector];
                void (*func)(id, SEL, id, id,id) = (void *)imp;
                func(instance, selector, nil, nil,nil);
            }
            NSLog(@"ClassName: %@ MethodName: %@,ArgumentCount: %d,RCMethodType:%lu --- End", [instance class], method.methodName,
                  method.argumentCount,method.methodType);
        }
    }
}

+ (void)excuteClassMethod:(Class)cla methodList:(NSArray<RCMethodModel *> *)methodList {
    for (RCMethodModel *method in methodList) {
        SEL selector = NSSelectorFromString(method.methodName);
        if ([cla respondsToSelector:selector]) {
            NSLog(@"ClassName: %@ MethodName: %@,ArgumentCount: %d,RCMethodType:%lu --- Begin", [cla class], method.methodName,
                  method.argumentCount,method.methodType);
            if (method.argumentCount == 2) {
                IMP imp = [cla methodForSelector:selector];
                void (*func)(id, SEL) = (void *)imp;
                func(cla, selector);
            }
            if (method.argumentCount == 3) {
                IMP imp = [cla methodForSelector:selector];
                void (*func)(id, SEL, id) = (void *)imp;
                func(cla, selector, nil);
            }
            if (method.argumentCount == 4) {
                IMP imp = [cla methodForSelector:selector];
                void (*func)(id, SEL, id, id) = (void *)imp;
                func(cla, selector, nil, nil);
            }
            if (method.argumentCount == 5) {
                IMP imp = [cla methodForSelector:selector];
                void (*func)(id, SEL, id, id,id) = (void *)imp;
                func(cla, selector, nil, nil,nil);
            }
            NSLog(@"ClassName: %@ MethodName: %@,ArgumentCount: %d,RCMethodType:%lu --- End", [cla class], method.methodName,
                  method.argumentCount,method.methodType);
        }
    }
}

+ (void)excuteMethodArgumentWithNil:(NSObject *)instance{
    [RCTestHelper excuteMethodArgumentWithNil:instance except:nil];
}

+ (void)excuteMethodArgumentWithNil:(NSObject *)instance except:(NSDictionary *)exceptMethods{
    NSArray<RCMethodModel *> *instanceMethodList = [RCTestHelper getAllInstanceMethods:[instance class] except:exceptMethods];
    [self excuteInstanceMethod:instance methodList:instanceMethodList];
 
   NSArray<RCMethodModel *> *classMethodList = [RCTestHelper getAllClassMethods:[instance class] except:exceptMethods];
   [self excuteClassMethod:[instance class] methodList:classMethodList];
}
+ (void)excuteClassMethod:(Class)cla except:(NSDictionary *)exceptMethods{
    NSArray<RCMethodModel *> *classMethodList = [RCTestHelper getAllClassMethods:cla except:exceptMethods];
    [self excuteClassMethod:cla methodList:classMethodList];
}

+ (void)excuteInstanceMethod:(NSObject *)instance except:(NSDictionary *)exceptMethods{
    NSArray<RCMethodModel *> *instanceMethodList = [RCTestHelper getAllInstanceMethods:[instance class] except:exceptMethods];
    [self excuteInstanceMethod:instance methodList:instanceMethodList];
}

+ (UIImage *)fixOrientation:(UIImage *)image withOrientation:(UIImageOrientation)imageOrientation{
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;

    switch (imageOrientation) {
    case UIImageOrientationDown:
    case UIImageOrientationDownMirrored:
        transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
        transform = CGAffineTransformRotate(transform, M_PI);
        break;

    case UIImageOrientationLeft:
    case UIImageOrientationLeftMirrored:
        transform = CGAffineTransformTranslate(transform, image.size.width, 0);
        transform = CGAffineTransformRotate(transform, M_PI_2);
        break;

    case UIImageOrientationRight:
    case UIImageOrientationRightMirrored:
        transform = CGAffineTransformTranslate(transform, 0, image.size.height);
        transform = CGAffineTransformRotate(transform, -M_PI_2);
        break;
    default:
        break;
    }

    switch (imageOrientation) {
    case UIImageOrientationUpMirrored:
    case UIImageOrientationDownMirrored:
        transform = CGAffineTransformTranslate(transform, image.size.width, 0);
        transform = CGAffineTransformScale(transform, -1, 1);
        break;

    case UIImageOrientationLeftMirrored:
    case UIImageOrientationRightMirrored:
        transform = CGAffineTransformTranslate(transform, image.size.height, 0);
        transform = CGAffineTransformScale(transform, -1, 1);
        break;
    default:
        break;
    }

    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx =
        CGBitmapContextCreate(NULL, image.size.width, image.size.height, CGImageGetBitsPerComponent(image.CGImage), 0,
                              CGImageGetColorSpace(image.CGImage), CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (imageOrientation) {
    case UIImageOrientationLeft:
    case UIImageOrientationLeftMirrored:
    case UIImageOrientationRight:
    case UIImageOrientationRightMirrored:
        // Grr...
        CGContextDrawImage(ctx, CGRectMake(0, 0, image.size.height, image.size.width), image.CGImage);
        break;

    default:
        CGContextDrawImage(ctx, CGRectMake(0, 0, image.size.width, image.size.height), image.CGImage);
        break;
    }

    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

@end
