//
//  MFTestEnvironmentHelpers.m
//  Obsidian
//
//  Created by Michaël Fortin on 11/21/2013.
//  Copyright (c) 2013 irradiated.net. All rights reserved.
//

#import "MFTestEnvironmentHelpers.h"
#import "MFDirectory.h"
#import "NSException+Additions.h"
#if TARGET_OS_IPHONE
	#import "MFDirectory+iOS.h"
#else
	#import "MFDirectory+OSX.h"
#endif

@implementation MFTestEnvironmentHelpers

#pragma mark Test Files Management

+ (MFDirectory *)testDirectory
{
	return [MFDirectory directoryWithPath:@"/Library/Caches/net.irradiated.Tests"];
}

// Note: This method uses MFDirectory and MFFile even though those are most probably the classes under test
// but it's OK because if they fail at their task we won't even be able to proceed to the tests themselves anyway
// so guaranteed failure if the classes are non-functional.
+ (void)cleanupAndCopyTestFilesToTestDirectoryFromBundleResources
{
	NSBundle *testBundle = [NSBundle bundleForClass:[self class]];
	MFDirectory *testFiles = [[MFDirectory resourcesInBundle:testBundle] subdirectory:@"TestFiles.noindex"];
	
	[[self testDirectory] deleteContents];
	
	if (![testFiles copyContentsTo:[self testDirectory]])
		@throw [NSException exceptionWithReason:@"Could not copy files for testing!"];
}

@end
