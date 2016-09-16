//
//  TestEnvironmentHelpers.h
//  Obsidian
//
//  Created by Michaël Fortin on 11/21/2013.
//  Copyright (c) 2013 irradiated.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Directory.h"

@interface TestEnvironmentHelpers : NSObject

#pragma mark Test Files Management

+ (Directory *)testDirectory;
+ (void)cleanupAndCopyTestFilesToTestDirectoryFromBundleResources;

@end
