//
//  EasyUnarchive.m
//  DemoForZipx
//
//  Created by Darklinden on 5/22/12.
//  Copyright (c) 2012 darklinden. All rights reserved.
//

#import "EasyUnarchive.h"
#import "XADSimpleUnarchiver.h"

@interface EasyUnarchive (/* private */)
@property (nonatomic, assign) id<EasyUnarchiveDelegate>     delegate;
@property (nonatomic, retain) NSString                      *filepath;
@property (nonatomic, retain) NSString                      *fileName;
@property (nonatomic, retain) NSString                      *fileFolder;
@property (nonatomic, retain) NSMutableArray                *pArray_contents;
@property (nonatomic, retain) NSString                      *pStr_password;
@property (nonatomic, assign) BOOL                          bool_unarchiveCanceled;
@property (nonatomic, retain) NSNumber                      *pEncoding;
@property (nonatomic, retain) NSArray                       *pArray_pathToUnArchive;
@property (nonatomic, retain) NSThread                      *pThread_exe;
@property (nonatomic, retain) NSDictionary                  *pDict_settings;
@property (nonatomic, retain) NSString                      *errMsg;
@end

@implementation EasyUnarchive
@synthesize delegate;
@synthesize filepath;
@synthesize fileName;
@synthesize fileFolder;
@synthesize pArray_contents;
@synthesize pStr_password;
@synthesize bool_unarchiveCanceled;
@synthesize pEncoding;
@synthesize pArray_pathToUnArchive;
@synthesize pThread_exe;
@synthesize pDict_settings;
@synthesize errMsg;

+ (id)sharedEasyUnarchive
{
    static EasyUnarchive *staticEasyUnarchive = nil;
    if (!staticEasyUnarchive) {
        staticEasyUnarchive = [[EasyUnarchive alloc] init];
        staticEasyUnarchive.pDict_settings = [NSDictionary dictionaryWithObjectsAndKeys:
                                              @"80", KEY_autoDetectionThreshold,
                                              nil];
    }
    return staticEasyUnarchive;
}

#pragma mark - life circle
- (void)dealloc
{
    [filepath release], filepath = nil;
    [fileName release], fileName = nil;
    [fileFolder release], fileFolder = nil;
    [pArray_contents release], pArray_contents = nil;
    [pStr_password release], pStr_password = nil;
    [pEncoding release], pEncoding = nil;
    [pArray_pathToUnArchive release], pArray_pathToUnArchive = nil;
    [pThread_exe release], pThread_exe = nil;
    [pDict_settings release], pDict_settings = nil;
    [errMsg release], errMsg = nil;
    [super dealloc];
}

+ (BOOL)isExecuting
{
    EasyUnarchive *pEasyUnarchive = [self sharedEasyUnarchive];
    return pEasyUnarchive.pThread_exe.isExecuting;
}

+ (BOOL)requestContentWithDelegate:(id)delegate file:(NSString *)filePath
{
    EasyUnarchive *pEasyUnarchive = [self sharedEasyUnarchive];
    pEasyUnarchive.delegate = delegate;
    
    if ([pEasyUnarchive.pThread_exe isExecuting]) {
        return NO;
    }
    else {
        [pEasyUnarchive setFilepath:filePath];
        [pEasyUnarchive setFileName:filePath.lastPathComponent];
        
        NSString *base = [filePath stringByDeletingPathExtension];
        NSString *dest = base;
        int n = 1;
        while([[NSFileManager defaultManager] fileExistsAtPath:dest])
            dest = [NSString stringWithFormat:@"%@ (%d)", base, n++];
        
        [pEasyUnarchive setFileFolder:dest];
        
        pEasyUnarchive.pEncoding = nil;
        pEasyUnarchive.pArray_contents = nil;
        pEasyUnarchive.bool_unarchiveCanceled = NO;
        pEasyUnarchive.pStr_password = nil;
        pEasyUnarchive.pThread_exe = [[[NSThread alloc] initWithTarget:pEasyUnarchive selector:@selector(threadGetContentFiles) object:nil] autorelease];
        [pEasyUnarchive.pThread_exe start];
        
        return YES;
    }
}

+ (BOOL)requestUnarchiveWithDelegate:(id)delegate
                                file:(NSString *)filePath
                       selectedFiles:(NSArray *)array
{
    EasyUnarchive *pEasyUnarchive = [self sharedEasyUnarchive];
    pEasyUnarchive.delegate = delegate;
    
    if ([pEasyUnarchive.pThread_exe isExecuting]) {
        return NO;
    }
    else {
        [pEasyUnarchive setFilepath:filePath];
        [pEasyUnarchive setFileName:filePath.lastPathComponent];
        
        NSString *base = [filePath stringByDeletingPathExtension];
        NSString *dest = base;
        int n = 1;
        while([[NSFileManager defaultManager] fileExistsAtPath:dest])
            dest = [NSString stringWithFormat:@"%@ (%d)", base, n++];
        
        [pEasyUnarchive setFileFolder:dest];
        
        pEasyUnarchive.pEncoding = nil;
        pEasyUnarchive.pArray_pathToUnArchive = array;
        pEasyUnarchive.pArray_contents = nil;
        pEasyUnarchive.bool_unarchiveCanceled = NO;
        pEasyUnarchive.pStr_password = nil;
        pEasyUnarchive.pThread_exe = [[[NSThread alloc] initWithTarget:pEasyUnarchive selector:@selector(threadUnarchive) object:nil] autorelease];
        [pEasyUnarchive.pThread_exe start];
        
        return YES;
    }
}

+ (void)setPassword:(NSString*)apass
{
    EasyUnarchive *pEasyUnarchive = [self sharedEasyUnarchive];
    [pEasyUnarchive setPassword:apass];
}

- (void)setPassword:(NSString*)apass
{
    @synchronized (pStr_password) {
        if (apass) {
            self.pStr_password = apass;
        }
        else {
            self.pStr_password = @"";
        }
    }
}

+ (void)setEncoding:(NSNumber *)aencoding
{
    EasyUnarchive *pEasyUnarchive = [self sharedEasyUnarchive];
    [pEasyUnarchive setEncoding:aencoding];
}

- (void)setEncoding:(NSNumber *)aencoding
{
    @synchronized (pEncoding) {
        self.pEncoding = aencoding;
    }
}

+ (void)cancel
{
    EasyUnarchive *pEasyUnarchive = [self sharedEasyUnarchive];
    [pEasyUnarchive cancel];
}

- (void)cancel
{
    self.bool_unarchiveCanceled = YES;
    @synchronized (pStr_password) {
        self.pStr_password = @"";
    }
    @synchronized (pEncoding) {
        self.pEncoding = [NSNumber numberWithInteger:0];
    }
}

#pragma mark - main thread func
- (void)didParsedFile:(NSString*)err
{
    if (delegate) {
        if ([delegate respondsToSelector:@selector(didParsedFileContents:withError:)]) {
            [delegate didParsedFileContents:self.pArray_contents withError:err];
        }
    }
}

- (void)needPassword
{
    if (delegate) {
        if ([delegate respondsToSelector:@selector(needPassword)]) {
            [delegate needPassword];
        }
    }
}

- (void)needEncoding:(NSArray *)array
{
    if (delegate) {
        if ([delegate respondsToSelector:@selector(needEncoding:)]) {
            [delegate needEncoding:array];
        }
    }
}

- (void)didUnarchived:(NSString*)err
{
    if (err) {
        [[NSFileManager defaultManager] removeItemAtPath:self.fileFolder error:nil];
    }
    if (delegate) {
        if ([delegate respondsToSelector:@selector(didFinishUnarchiveToFolder:withError:)]) {
            [delegate didFinishUnarchiveToFolder:self.fileFolder withError:err];
        }
    }
}

#pragma mark - bg thread func
- (void)threadGetContentFiles
{
    @autoreleasepool {
        self.errMsg = nil;
        XADSimpleUnarchiver *pArchiveFilePaser = [[XADSimpleUnarchiver simpleUnarchiverForPath:self.filepath error:NULL] retain];
        if(!pArchiveFilePaser)
        {
            self.errMsg = @"file open failed";
        }
        else {
            [pArchiveFilePaser setDelegate:self];
            [pArchiveFilePaser setPropagatesRelevantMetadata:YES];
            [pArchiveFilePaser setAlwaysRenamesFiles:YES];
            [pArchiveFilePaser setCopiesArchiveModificationTimeToEnclosingDirectory:NO];
            [pArchiveFilePaser setCopiesArchiveModificationTimeToSoloItems:NO];
            [pArchiveFilePaser setResetsDateForSoloItems:NO];
            [pArchiveFilePaser setDestination:self.fileFolder];
            [pArchiveFilePaser setRemovesEnclosingDirectoryForSoloItems:YES];
            
            XADError error = [pArchiveFilePaser parse];
            NSString *_errMsg = nil;
            if(error == XADBreakError)
            {
                _errMsg = @"user canceled";
            }
            else if(error)
            {
                _errMsg = [XADException describeXADError:error];
            }
            
            self.pArray_contents = [NSArray arrayWithArray:[pArchiveFilePaser parsedEntries]];
            
            for (NSMutableDictionary *dict in self.pArray_contents) {
                if (self.bool_unarchiveCanceled) {
                    break;
                }
                XADPath *xadpath = [dict objectForKey:XADFileNameKey];
                NSString *encodingname = nil;
                if(![xadpath encodingIsKnown])
                {
                    encodingname = [self simpleUnarchiver:nil encodingNameForXADString:xadpath];
                    if(!encodingname) continue;
                }
                
                NSString *safefilename;
                if(encodingname) safefilename=[xadpath sanitizedPathStringWithEncodingName:encodingname];
                else safefilename=[xadpath sanitizedPathString];
                
                [dict setObject:safefilename forKey:XADFileNameKey];
            }
            
            if (!self.errMsg) {
                self.errMsg = _errMsg;
            }
            
            pArchiveFilePaser.delegate = nil;
            [pArchiveFilePaser release], pArchiveFilePaser = nil;
        }
        
        [self performSelectorOnMainThread:@selector(didParsedFile:) withObject:self.errMsg waitUntilDone:NO];
    }
}

- (void)threadUnarchive
{
    @autoreleasepool {
        self.errMsg = nil;
        XADSimpleUnarchiver *pUnArchiver = [[XADSimpleUnarchiver simpleUnarchiverForPath:self.filepath error:NULL] retain];
        if(!pUnArchiver)
        {
            self.errMsg = @"file open failed";
        }
        else {
            [pUnArchiver setDelegate:self];
            [pUnArchiver setPropagatesRelevantMetadata:YES];
            [pUnArchiver setAlwaysRenamesFiles:YES];
            [pUnArchiver setCopiesArchiveModificationTimeToEnclosingDirectory:NO];
            [pUnArchiver setCopiesArchiveModificationTimeToSoloItems:NO];
            [pUnArchiver setResetsDateForSoloItems:NO];
            [pUnArchiver setDestination:self.fileFolder];
            [pUnArchiver setRemovesEnclosingDirectoryForSoloItems:YES];
            [pUnArchiver setExtractsSubArchives:NO];
            
            XADError error = [pUnArchiver parse];
            NSString *_errMsg = nil;
            if(error == XADBreakError)
            {
                _errMsg = @"user canceled";
            }
            else if(error)
            {
                _errMsg = [XADException describeXADError:error];
            }
            
            error = [pUnArchiver unarchive];
            if(error)
            {
                _errMsg = [XADException describeXADError:error];
            }
            
            if (!self.errMsg) {
                self.errMsg = _errMsg;
            }
            
            pUnArchiver.delegate = nil;
            [pUnArchiver release], pUnArchiver = nil;
        }
        [self performSelectorOnMainThread:@selector(didUnarchived:) withObject:self.errMsg waitUntilDone:NO];
    }
}

#pragma mark - unarchiver delegate
- (void)simpleUnarchiverNeedsPassword:(XADSimpleUnarchiver *)unarchiver
{
    BOOL bool_passwordOK = NO;
    [self performSelectorOnMainThread:@selector(needPassword) withObject:nil waitUntilDone:NO];
    while (!bool_passwordOK) {
        @synchronized (pStr_password) {
            bool_passwordOK = (pStr_password != nil);
        }
        [NSThread sleepForTimeInterval:0.5f];
        //        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
    }
    [unarchiver setPassword:self.pStr_password];
    [unarchiver setPassword:self.pStr_password];
}

- (BOOL)simpleUnarchiver:(XADSimpleUnarchiver *)unarchiver shouldExtractEntryWithDictionary:(NSDictionary *)dict to:(NSString *)path
{
    if (self.pArray_pathToUnArchive) {
        NSString *relativePath = [[path substringFromIndex:fileFolder.length + 1] retain];
        BOOL shouldExtract = NO;
        for (NSDictionary *dict in self.pArray_pathToUnArchive) {
            NSString *name = [NSString stringWithFormat:@"%@", [dict objectForKey:KEY_XADFileNameKey]];
            NSString *isDirectory = [NSString stringWithFormat:@"%@", [dict objectForKey:KEY_XADIsDirectoryKey]];
            if ([isDirectory isEqualToString:@"1"]) {
                if (relativePath.length > name.length + 1) {
                    if ([[relativePath substringToIndex:name.length + 1] isEqualToString:[NSString stringWithFormat:@"%@/", name]]) {
                        shouldExtract = YES;
                        break;
                    }
                }
                else if (relativePath.length == name.length) {
                    if ([relativePath isEqualToString:name]) {
                        shouldExtract = YES;
                        break;
                    }
                }
                else if (relativePath.length < name.length) {
                    if ([[name substringToIndex:relativePath.length + 1] isEqualToString:[NSString stringWithFormat:@"%@/", relativePath]]) {
                        shouldExtract = YES;
                        break;
                    }
                }
            }
            else {
                if ([relativePath isEqualToString:name]) {
                    shouldExtract = YES;
                    break;
                }
            }
        }
        
        [relativePath release];
        return shouldExtract;
    }
    else {
        return YES;
    }
}

- (NSString *)stringForXADPath:(XADPath *)path
{
	NSStringEncoding encoding=[self.pEncoding integerValue];
	if(!encoding) encoding=[path encoding];
	return [path stringWithEncoding:encoding];
}

- (void)simpleUnarchiver:(XADSimpleUnarchiver *)sender didExtractEntryWithDictionary:(NSDictionary *)dict to:(NSString *)path error:(XADError)error
{
    if(self.bool_unarchiveCanceled) return;
    
	if(error)
	{
        self.bool_unarchiveCanceled = YES;
        self.errMsg = [XADException describeXADError:error];
	}
}

- (BOOL)extractionShouldStopForSimpleUnarchiver:(XADSimpleUnarchiver *)unarchiver
{
    return bool_unarchiveCanceled;
}

- (void)simpleUnarchiver:(XADSimpleUnarchiver *)unarchiver
extractionProgressForEntryWithDictionary:(NSDictionary *)dict
            fileProgress:(off_t)fileprogress of:(off_t)filesize
           totalProgress:(off_t)totalprogress of:(off_t)totalsize
{
    //    NSLog(@"%lld %lld %lld %lld", fileprogress, filesize, totalprogress, totalsize);
}

static NSInteger encoding_sort(id enc1, id enc2, void *context)
{
	NSInteger encoding1 = [enc1 integerValue];
	NSInteger encoding2 = [enc2 integerValue];
    return encoding1 > encoding2 ? 1 : -1;
}

+ (NSArray *)encodings
{
	NSMutableArray *encodingarray = [NSMutableArray array];
	const CFStringEncoding *encodings = CFStringGetListOfAvailableEncodings();
    
	while (*encodings != kCFStringEncodingInvalidId)
	{
		CFStringEncoding cfencoding = *encodings++;
		NSString *name = [NSString localizedNameOfStringEncoding:CFStringConvertEncodingToNSStringEncoding(cfencoding)];
		NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(cfencoding);
        
		if (!name) continue;
		if (encoding == 10) continue;
		[encodingarray addObject:[NSNumber numberWithInteger:encoding]];
	}
    
	return [encodingarray sortedArrayUsingFunction:encoding_sort context:nil];
}

static BOOL IsSurrogateHighCharacter(unichar c)
{
    return c >= 0xd800 && c <= 0xdbff;
}

static BOOL IsSurrogateLowCharacter(unichar c)
{
    return c >= 0xdc00 && c <= 0xdfff;
}

static BOOL SanityCheckString(NSString *string)
{
	int length = [string length];
	for (int i = 0; i < length; i++)
	{
		unichar c = [string characterAtIndex:i];
		if (IsSurrogateHighCharacter(c)) return NO;
		if (IsSurrogateLowCharacter(c))
		{
			i++;
			if(i >= length) return NO;
			unichar c2 = [string characterAtIndex:i];
			if (!IsSurrogateHighCharacter(c2)) return NO;
		}
	}
	return YES;
}

- (NSArray *)buildEncodingListMatchingXADString:(id <XADString>)string
{
	NSArray *encodings = [[self class] encodings];
	NSEnumerator *enumerator = [encodings objectEnumerator];
	NSNumber *ennum = nil;
    NSMutableArray *array = [NSMutableArray array];
    
	while((ennum = [enumerator nextObject]))
	{
		NSStringEncoding encoding = [ennum integerValue];
		if(string && ![string canDecodeWithEncoding:encoding]) continue;
        NSLog(@"%u", encoding);
        NSMutableDictionary *item = [NSMutableDictionary dictionary];
		if (string) {
			NSString *decoded = [string stringWithEncoding:encoding];
			if (!SanityCheckString(decoded)) continue;
            
            [item setObject:decoded forKey:KEY_Decoded];
            [item setObject:[NSNumber numberWithInteger:encoding] forKey:KEY_Encoding];
            [array addObject:item];
		}
	}
    return [NSArray arrayWithArray:array];
}

- (NSString *)simpleUnarchiver:(XADSimpleUnarchiver *)unarchiver encodingNameForXADString:(id<XADString>)string
{
    if (bool_unarchiveCanceled) {
        return nil;
    }
    
	// If the user has already been asked for an encoding, try to use it.
	// Otherwise, if the confidence in the guessed encoding is high enough, try that.
	int threshold = [[pDict_settings objectForKey:KEY_autoDetectionThreshold] integerValue];
    
	NSStringEncoding encoding = 0;
	if (pEncoding) encoding = [pEncoding integerValue];
	else if([string confidence] * 100 >= threshold) encoding = [string encoding];
    
	// If we have an encoding we trust, and it can decode the string, use it.
	if(encoding && [string canDecodeWithEncoding:encoding])
        return [XADString encodingNameForEncoding:encoding];
    
	// Otherwise, ask the user for an encoding.
    BOOL bool_encodingOK = NO;
    
    NSArray *array = [self buildEncodingListMatchingXADString:string];
    
    [self performSelectorOnMainThread:@selector(needEncoding:) withObject:array waitUntilDone:NO];
    while (!bool_encodingOK) {
        @synchronized (pEncoding) {
            bool_encodingOK = (pEncoding != nil);
        }
        [NSThread sleepForTimeInterval:0.5f];
        //        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
    }
    
    if ([pEncoding integerValue] == 0) return nil;
    
	return [XADString encodingNameForEncoding:[pEncoding integerValue]];
}

#pragma mark - encode example
+ (void)encodeExample
{
    const Byte byte[17] = {0xD0,0xC2,0xBD,0xA8,0x20,0xCE,0xC4,0xB1,0xBE,0xCE,0xC4,0xB5,0xB5,0x2E,0x74,0x78,0x74};
    NSString *strfileName = [NSString stringWithUTF8String:(const char *)byte];
    
    NSData *data = [NSData dataWithBytes:byte length:17];
    XADStringSource *source = [[[XADStringSource alloc] init] autorelease];
    [source analyzeData:data];
    NSString *str = [XADString escapedStringForBytes:byte length:17 encodingName:[source encodingName]];
    
    NSLog(@"%@", strfileName);
    NSLog(@"%@", [source encodingName]);
    NSLog(@"%d", [source encoding]);
    NSLog(@"%@", str);
}

+ (NSString *)nameOfEncoding:(NSStringEncoding)encoding
{
    NSString *pStr_ret = nil;
    switch (encoding) {
        case 2147484697:
            pStr_ret = @"Arabic (DOS)";
            break;
        case 2147483652:
            pStr_ret = @"Arabic (Mac OS)";
            break;
        case 2147484934:
            pStr_ret = @"Arabic (Windows)";
            break;
        case 2147484678:
            pStr_ret = @"Baltic (DOS)";
            break;
        case 2147484173:
            pStr_ret = @"Baltic (ISO Latin 7)";
            break;
        case 2147484935:
            pStr_ret = @"Baltic (Windows)";
            break;
        case 2147484696:
            pStr_ret = @"Canadian French (DOS)";
            break;
        case 2147484174:
            pStr_ret = @"Celtic (ISO Latin 8)";
            break;
        case 2147483687:
            pStr_ret = @"Celtic (Mac OS)";
            break;
        case 2147484690:
            pStr_ret = @"Central European (DOS Latin 2)";
            break;
        case 9:
            pStr_ret = @"Central European (ISO Latin 2)";
            break;
        case 2147484164:
            pStr_ret = @"Central European (ISO Latin 4)";
            break;
        case 2147483677:
            pStr_ret = @"Central European (Mac OS)";
            break;
        case 15:
            pStr_ret = @"Central European (Windows Latin 2)";
            break;
        case 2147485234:
            pStr_ret = @"Chinese (GB 18030)";
            break;
        case 2147485233:
            pStr_ret = @"Chinese (GBK)";
            break;
        case 2147483684:
            pStr_ret = @"Croatian (Mac OS)";
            break;
        case 2147484691:
            pStr_ret = @"Cyrillic (DOS)";
            break;
        case 2147484165:
            pStr_ret = @"Cyrillic (ISO 8859-5)";
            break;
        case 2147486210:
            pStr_ret = @"Cyrillic (KOI8-R)";
            break;
        case 2147483800:
            pStr_ret = @"Cyrillic (Mac OS Ukrainian)";
            break;
        case 2147483655:
            pStr_ret = @"Cyrillic (Mac OS)";
            break;
        case 11:
            pStr_ret = @"Cyrillic (Windows)";
            break;
        case 2147483657:
            pStr_ret = @"Devanagari (Mac OS)";
            break;
        case 2147483682:
            pStr_ret = @"Dingbats (Mac OS)";
            break;
        case 2147483788:
            pStr_ret = @"Farsi (Mac OS)";
            break;
        case 2147483688:
            pStr_ret = @"Gaelic (Mac OS)";
            break;
        case 2147484689:
            pStr_ret = @"Greek (DOS Greek 1)";
            break;
        case 2147484700:
            pStr_ret = @"Greek (DOS Greek 2)";
            break;
        case 2147484677:
            pStr_ret = @"Greek (DOS)";
            break;
        case 2147484167:
            pStr_ret = @"Greek (ISO 8859-7)";
            break;
        case 2147483654:
            pStr_ret = @"Greek (Mac OS)";
            break;
        case 13:
            pStr_ret = @"Greek (Windows)";
            break;
        case 2147483659:
            pStr_ret = @"Gujarati (Mac OS)";
            break;
        case 2147483658:
            pStr_ret = @"Gurmukhi (Mac OS)";
            break;
        case 2147484695:
            pStr_ret = @"Hebrew (DOS)";
            break;
        case 2147483653:
            pStr_ret = @"Hebrew (Mac OS)";
            break;
        case 2147484933:
            pStr_ret = @"Hebrew (Windows)";
            break;
        case 2147484694:
            pStr_ret = @"Icelandic (DOS)";
            break;
        case 2147483685:
            pStr_ret = @"Icelandic (Mac OS)";
            break;
        case 2147483884:
            pStr_ret = @"Inuit (Mac OS)";
            break;
        case 3:
            pStr_ret = @"Japanese (EUC)";
            break;
        case 21:
            pStr_ret = @"Japanese (ISO 2022-JP)";
            break;
        case 2147483649:
            pStr_ret = @"Japanese (Mac OS)";
            break;
        case 2147485224:
            pStr_ret = @"Japanese (Shift JIS X0213)";
            break;
        case 2147486209:
            pStr_ret = @"Japanese (Shift JIS)";
            break;
        case 8:
            pStr_ret = @"Japanese (Windows, DOS)";
            break;
        case 2147486016:
            pStr_ret = @"Korean (EUC)";
            break;
        case 2147485760:
            pStr_ret = @"Korean (ISO 2022-KR)";
            break;
        case 2147483651:
            pStr_ret = @"Korean (Mac OS)";
            break;
        case 2147484706:
            pStr_ret = @"Korean (Windows, DOS)";
            break;
        case 2147484672:
            pStr_ret = @"Latin-US (DOS)";
            break;
        case 2147484698:
            pStr_ret = @"Nordic (DOS)";
            break;
        case 2147484170:
            pStr_ret = @"Nordic (ISO Latin 6)";
            break;
        case 2147484693:
            pStr_ret = @"Portuguese (DOS)";
            break;
        case 2147484176:
            pStr_ret = @"Romanian (ISO Latin 10)";
            break;
        case 2147483686:
            pStr_ret = @"Romanian (Mac OS)";
            break;
        case 2147484699:
            pStr_ret = @"Russian (DOS)";
            break;
        case 2147486000:
            pStr_ret = @"Simplified Chinese (GB 2312)";
            break;
        case 2147486213:
            pStr_ret = @"Simplified Chinese (HZ GB 2312)";
            break;
        case 2147483673:
            pStr_ret = @"Simplified Chinese (Mac OS)";
            break;
        case 2147484705:
            pStr_ret = @"Simplified Chinese (Windows, DOS)";
            break;
        case 6:
            pStr_ret = @"Symbol (Mac OS)";
            break;
        case 2147484171:
            pStr_ret = @"Thai (ISO 8859-11)";
            break;
        case 2147483669:
            pStr_ret = @"Thai (Mac OS)";
            break;
        case 2147484701:
            pStr_ret = @"Thai (Windows, DOS)";
            break;
        case 2147486214:
            pStr_ret = @"Traditional Chinese (Big 5 HKSCS)";
            break;
        case 2147486211:
            pStr_ret = @"Traditional Chinese (Big 5)";
            break;
        case 2147486217:
            pStr_ret = @"Traditional Chinese (Big 5-E)";
            break;
        case 2147486001:
            pStr_ret = @"Traditional Chinese (EUC)";
            break;
        case 2147483650:
            pStr_ret = @"Traditional Chinese (Mac OS)";
            break;
        case 2147484707:
            pStr_ret = @"Traditional Chinese (Windows, DOS)";
            break;
        case 2147484692:
            pStr_ret = @"Turkish (DOS)";
            break;
        case 2147484169:
            pStr_ret = @"Turkish (ISO Latin 5)";
            break;
        case 2147483683:
            pStr_ret = @"Turkish (Mac OS)";
            break;
        case 14:
            pStr_ret = @"Turkish (Windows Latin 5)";
            break;
        case 2147486216:
            pStr_ret = @"Ukrainian (KOI8-U)";
            break;
        case 2415919360:
            pStr_ret = @"Unicode (UTF-16BE)";
            break;
        case 2483028224:
            pStr_ret = @"Unicode (UTF-16LE)";
            break;
        case 2147484936:
            pStr_ret = @"Vietnamese (Windows)";
            break;
        case 1:
            pStr_ret = @"Western (ASCII)";
            break;
        case 2147484688:
            pStr_ret = @"Western (DOS Latin 1)";
            break;
        case 2147486722:
            pStr_ret = @"Western (EBCDIC Latin 1)";
            break;
        case 5:
            pStr_ret = @"Western (ISO Latin 1)";
            break;
        case 2147484175:
            pStr_ret = @"Western (ISO Latin 9)";
            break;
        case 2147486212:
            pStr_ret = @"Western (Mac Mail)";
            break;
        case 30:
            pStr_ret = @"Western (Mac OS Roman)";
            break;
        case 2:
            pStr_ret = @"Western (NextStep)";
            break;
        case 12:
            pStr_ret = @"Western (Windows Latin 1)";
            break;
        default:
            break;
    }
    return pStr_ret;
}

@end
