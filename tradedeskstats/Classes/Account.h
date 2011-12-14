//
//  Account.h
//  Trade Desk Stats
//
//  Created by Alex Pylko on 11/23/11.
//  Copyright (c) 2011 alexpylko@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Account : NSObject

@property (nonatomic) NSInteger uniqueId;

@property (nonatomic, retain) NSString *  name;

@property (nonatomic, retain) NSString * dateString;

-(id)initWithUniqueId:(NSInteger)aUniqueId name:(NSString*)aName dateString:(NSString*)aDateString;

-(id)initWithName:(NSString*)aName;

-(void)applyCurrentDate;

@end
