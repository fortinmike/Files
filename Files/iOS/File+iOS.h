//
//  File+iOS.h
//  Obsidian
//
//  Created by Michaël Fortin on 11/23/2013.
//  Copyright (c) 2013 irradiated.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "File.h"

@interface File (iOS)

#pragma mark Reading Specific Types

- (UIImage *)readImage;

@end
