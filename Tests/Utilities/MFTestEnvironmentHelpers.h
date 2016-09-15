//
//  MFTestEnvironmentHelpers.h
//  Obsidian
//
//  Created by Michaël Fortin on 11/21/2013.
//  Copyright (c) 2013 irradiated.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MFDirectory.h"

@interface MFTestEnvironmentHelpers : NSObject

#pragma mark Test Files Management

+ (MFDirectory *)testDirectory;
+ (void)cleanupAndCopyTestFilesToTestDirectoryFromBundleResources;

@end
