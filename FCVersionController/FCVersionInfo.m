//
//  FCVersionInfo.m
//  FCVersionController
//
//  Created by Harley on 14/12/9.
//  Copyright (c) 2014年 Flycent. All rights reserved.
//

#import "FCVersionInfo.h"
#import "FCVersionController.h"


@implementation FCVersionInfo

- (instancetype)initWihtResponseDataJsonData:(NSDictionary*)jsonData searchingLocation:(FCUpdateSearchingLocation)location
{
    self = [super init];
    
    if (location == FCVersionSearchingLocation_FIR)
    {
        self.fullCode = [jsonData objectForKey:@"version"];
        self.shortCode = [jsonData objectForKey:@"versionShort"];
        self.releaseNotes = [jsonData objectForKey:@"changelog"];
        self.releaseURL = [jsonData objectForKey:@"update_url"];
    }
    else if (location == FCVersionSearchingLocation_AppStore)
    {
        NSArray *results = [jsonData objectForKey:@"results"];
        if (results.count <= 0) {
            return nil;
        }
        jsonData = [results firstObject];
        self.fullCode = [jsonData objectForKey:@"version"];
        self.shortCode = [jsonData objectForKey:@"version"];
        self.releaseNotes = [jsonData objectForKey:@"releaseNotes"];
        self.releaseURL = [jsonData objectForKey:@"trackViewUrl"];
    }
    else
    {
        return nil;
    }
    return self;
}

- (BOOL)sameAs:(FCVersionInfo*)info
{
    if (self.fullCode.length > 0 && info
        .fullCode.length > 0) {
        return [self.fullCode isEqualToString:info.fullCode];
    }
    return [self.shortCode isEqualToString:info.shortCode];
}

- (NSComparisonResult)compareWith:(FCVersionInfo*)info
{
    // 首先判断是否相等
    if ([self sameAs:info]) {
        return NSOrderedSame;
    }
    // 不相等则判断大小
    else if (self.fullCode.length > 0 && info
        .fullCode.length > 0) {
        return [self compareVersionCode:self.fullCode withVersionCode:info.fullCode];
    }else{
        return [self compareVersionCode:self.shortCode withVersionCode:info.shortCode];
    }

}


- (NSComparisonResult)compareVersionCode:(NSString*)code1 withVersionCode:(NSString*)code2
{
    NSArray *codes1 = [code1 componentsSeparatedByString:@"."];
    NSArray *codes2 = [code2 componentsSeparatedByString:@"."];
    
    // 逐个比较
    NSUInteger maxIndex = MAX(codes1.count, codes2.count);
    for (int i = 0; i < maxIndex; i++) {
        // 走到这一步说明某个版本号的长度大于另一个，并且之前的都是相同的，则认为较长的比较新
        if (codes1.count <= i || codes2.count <= i) {
            return codes1.count > codes2.count ? NSOrderedDescending : NSOrderedAscending;
        }
        // 走到这一步说明前面的各位都比较完毕，并且相同，需要比较当前位的大小
        else {
            long long number1 = [codes1[i] longLongValue];
            long long number2 = [codes2[i] longLongValue];

            // 当前位相同，比较下一位
            if (number1 == number2) {
                continue;
            }
            else {
                return number1 > number2 ? NSOrderedDescending : NSOrderedAscending;
            }
        }
    }
    // 走到这里说明两个长度相同，并且各个位上的值也都相同
    return NSOrderedSame;
}

@end
