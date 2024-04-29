//
//  AfAiLib.h
//  AfAiLib
//
//  Created by A$CE on 2019/5/15.
//  Copyright © 2019 Iwown. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AfAiLib : NSObject

+ (int)AfAiConfdenceLevel:(NSArray *)aiAfs;
+ (NSString *)AfAiResult:(NSArray *)aiAfs;

@end
