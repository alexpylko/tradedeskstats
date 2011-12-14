//
//  UIAlertView+Prompt.h
//  Trade Desk Stats
//
//  Created by Alex Pylko on 11/25/11.
//  Copyright (c) 2011 alexpylko@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertView (Prompt)

@property (nonatomic,readonly) NSString * promptValue;

-(void)prompt;

@end
