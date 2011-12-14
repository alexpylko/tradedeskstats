//
//  Account.m
//  Trade Desk Stats
//
//  Created by Alex Pylko on 11/23/11.
//  Copyright (c) 2011 alexpylko@gmail.com. All rights reserved.
//

#import "Account.h"

@implementation Account

@synthesize uniqueId;
@synthesize name;
@synthesize dateString;

-(id)initWithUniqueId:(NSInteger)aUniqueId name:(NSString*)aName dateString:(NSString*)aDateString;
{
    if( self = [super init] )
    {
        self.uniqueId = aUniqueId;
        self.name = aName;
        self.dateString = aDateString;
    }
    return self;
}

-(id)initWithName:(NSString*)aName;
{
    if( self = [super init] )
    {
        self.name = aName;
        [self applyCurrentDate];
    }
    return self;
}

-(void)applyCurrentDate;
{
    NSDateFormatter * dateFormater = [[NSDateFormatter alloc] init];
    dateFormater.dateFormat = @"yyyy-MM-dd HH:mm:ss ZZZ";
    self.dateString = [dateFormater stringFromDate:[NSDate date]];
    [dateFormater release];
}

-(void)dealloc;
{
    self.name = nil;
    self.dateString = nil;
    [super dealloc];
}

@end

