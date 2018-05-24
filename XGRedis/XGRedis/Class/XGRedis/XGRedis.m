//
//  XGRedis.m
//  SMG_NothingIsAll
//
//  Created by iMac on 2018/5/23.
//  Copyright © 2018年 XiaoGang. All rights reserved.
//

#import "XGRedis.h"
#import "XGRedisUtil.h"
#import "XGRedisDictionary.h"
#import "XGRedisPrefixHeader.h"

@interface XGRedis ()

@property (strong, nonatomic) XGRedisDictionary *dic;//核心字典

@end

@implementation XGRedis

-(id) init{
    self = [super init];
    if (self) {
        self.dic = [XGRedisDictionary sharedInstance];
    }
    return self;
}

-(void) setObject:(NSObject*)obj forKey:(NSString*)key {
    [self setObject:obj forKey:key time:NSNotFound];
}

-(void) setObject:(NSObject*)obj forKey:(NSString*)key time:(double)time{
    //1. 二分查找index;
    __block NSInteger findOldIndex = 0;
    [XGRedisUtil searchIndexWithCompare:^NSComparisonResult(NSInteger checkIndex) {
        NSString *checkKey = [self.dic keyForIndex:checkIndex];
        return [XGRedisUtil compareStrA:key strB:checkKey];
    } startIndex:0 endIndex:self.dic.count - 1 success:^(NSInteger index) {
        [self.dic removeObjectAtIndex:index];
        findOldIndex = index;
    } failure:^(NSInteger index) {
        findOldIndex = index;
    }];
    
     //2. 插入数据
     if(self.dic.count <= findOldIndex) {
         [self.dic addObject:obj forKey:key time:time];
     }else{
         [self.dic insertObject:obj key:key atIndex:findOldIndex time:time];
     }
}

-(NSObject*) objectForKey:(NSString*)key{
    //二分法查找
    __block NSObject *obj = nil;
    if (STRISOK(key)) {
        [XGRedisUtil searchIndexWithCompare:^NSComparisonResult(NSInteger checkIndex) {
            NSString *checkKey = [self.dic keyForIndex:checkIndex];
            return [XGRedisUtil compareStrA:key strB:checkKey];
        } startIndex:0 endIndex:self.dic.count - 1 success:^(NSInteger index) {
            obj = [self.dic valueForIndex:index];
        } failure:nil];
    }
    return obj;
}

@end
