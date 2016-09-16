//
//  TestEnvironmentHelpers.m
//  Obsidian
//
//  Created by Michaël Fortin on 11/21/2013.
//  Copyright (c) 2013 irradiated.net. All rights reserved.
//

#import "TestEnvironmentHelpers.h"
#import "Directory.h"
#import "NSException+FilesAdditions.h"
#if TARGET_OS_IPHONE
	#import "Directory+iOS.h"
#else
	#import "Directory+macOS.h"
#endif

@implementation TestEnvironmentHelpers

#pragma mark Test Files Management

+ (Directory *)testDirectory
{
	return [Directory directoryWithPath:@"/Library/Caches/net.irradiated.Tests"];
}

// Note: This method uses Directory and File even though those are most probably the classes under test
// but it's OK because if they fail at their task we won't even be able to proceed to the tests themselves anyway
// so guaranteed failure if the classes are non-functional.
+ (void)cleanupAndCopyTestFilesToTestDirectoryFromBundleResources
{
	NSBundle *testBundle = [NSBundle bundleForClass:[self class]];
	Directory *testFiles = [[Directory resourcesInBundle:testBundle] subdirectory:@"TestFiles.noindex"];
	
	[[self testDirectory] deleteContents];
	
	if (![testFiles copyContentsTo:[self testDirectory]])
		@throw [NSException exceptionWithReason:@"Could not copy files for testing!"];
}

@end
