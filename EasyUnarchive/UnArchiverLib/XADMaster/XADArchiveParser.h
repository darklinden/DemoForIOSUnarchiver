#import <Foundation/Foundation.h>
#import "XADException.h"
#import "XADString.h"
#import "XADPath.h"
#import "XADRegex.h"
#import "CSHandle.h"
#import "XADSkipHandle.h"
#import "XADResourceFork.h"
#import "Checksums.h"

#define XADFileNameKey                  @"FileName"
#define XADCommentKey                   @"Comment"
#define XADFileSizeKey                  @"FileSize"
#define XADCompressedSizeKey            @"CompressedSize"
#define XADCompressionNameKey           @"CompressionName"

#define XADIsDirectoryKey               @"IsDirectory"
#define XADIsResourceForkKey            @"IsResourceFork"
#define XADIsArchiveKey                 @"IsArchive"
#define XADIsHiddenKey                  @"IsHidden"
#define XADIsLinkKey                    @"IsLink"
#define XADIsHardLinkKey                @"IsHardLink"
#define XADLinkDestinationKey           @"LinkDestination"
#define XADIsCharacterDeviceKey         @"IsCharacterDevice"
#define XADIsBlockDeviceKey             @"IsBlockDevice"
#define XADDeviceMajorKey               @"DeviceMajor"
#define XADDeviceMinorKey               @"DeviceMinor"
#define XADIsFIFOKey                    @"IsFIFO"
#define XADIsEncryptedKey               @"IsEncrypted"
#define XADIsCorruptedKey               @"IsCorrupted"

#define XADLastModificationDateKey      @"LastModificationDate"
#define XADLastAccessDateKey            @"LastAccessDate"
#define XADLastAttributeChangeDateKey   @"LastAttributeChangeDate"
#define XADCreationDateKey              @"CreationDate"
#define XADExtendedAttributesKey        @"ExtendedAttributes"
#define XADFileTypeKey                  @"FileType"
#define XADFileCreatorKey               @"FileCreator"
#define XADFinderFlagsKey               @"FinderFlags"
#define XADFinderInfoKey                @"FinderInfo"
#define XADPosixPermissionsKey          @"PosixPermissions"
#define XADPosixUserKey                 @"PosixUser"
#define XADPosixGroupKey                @"PosixGroup"
#define XADPosixUserNameKey             @"PosixUserName"
#define XADPosixGroupNameKey            @"PosixGroupName"
#define XADDOSFileAttributesKey         @"DOSFileAttributes"
#define XADWindowsFileAttributesKey     @"WindowsFileAttributes"
#define XADAmigaProtectionBitsKey       @"AmigaProtectionBits"

#define XADIndexKey                     @"Index"
#define XADDataOffsetKey                @"DataOffset"
#define XADDataLengthKey                @"DataLength"
#define XADSkipOffsetKey                @"SkipOffset"
#define XADSkipLengthKey                @"SkipLength"

#define XADIsSolidKey                   @"IsSolid"
#define XADFirstSolidIndexKey           @"FirstSolidIndex"
#define XADFirstSolidEntryKey           @"FirstSolidEntry"
#define XADNextSolidIndexKey            @"NextSolidIndex"
#define XADNextSolidEntryKey            @"NextSolidEntry"
#define XADSolidObjectKey               @"SolidObject"
#define XADSolidOffsetKey               @"SolidOffset"
#define XADSolidLengthKey               @"SolidLength"

#define XADArchiveNameKey               @"ArchiveName"
#define XADVolumesKey                   @"Volumes"
#define XADDiskLabelKey                 @"DiskLabel"
#define XADLastBackupDateKey            @"XADLastBackupDate"
#define XADVolumeScanningFailedKey      @"XADVolumeScanningFailed"

@interface XADArchiveParser:NSObject
{
	CSHandle *sourcehandle;
	XADSkipHandle *skiphandle;
	XADResourceFork *resourcefork;

	id delegate;
	NSString *password;
	NSString *passwordencodingname;
	BOOL caresaboutpasswordencoding;

	NSMutableDictionary *properties;
	XADStringSource *stringsource;

	int currindex;

	id parsersolidobj;
	NSMutableDictionary *firstsoliddict,*prevsoliddict;
	id currsolidobj;
	CSHandle *currsolidhandle;
	BOOL forcesolid;

	BOOL shouldstop;
}

+(void)initialize;
+(Class)archiveParserClassForHandle:(CSHandle *)handle firstBytes:(NSData *)header
resourceFork:(XADResourceFork *)fork name:(NSString *)name propertiesToAdd:(NSMutableDictionary *)props;
+(XADArchiveParser *)archiveParserForHandle:(CSHandle *)handle name:(NSString *)name;
+(XADArchiveParser *)archiveParserForHandle:(CSHandle *)handle name:(NSString *)name error:(XADError *)errorptr;
+(XADArchiveParser *)archiveParserForHandle:(CSHandle *)handle resourceFork:(XADResourceFork *)fork name:(NSString *)name;
+(XADArchiveParser *)archiveParserForHandle:(CSHandle *)handle resourceFork:(XADResourceFork *)fork name:(NSString *)name error:(XADError *)errorptr;
+(XADArchiveParser *)archiveParserForHandle:(CSHandle *)handle firstBytes:(NSData *)header name:(NSString *)name;
+(XADArchiveParser *)archiveParserForHandle:(CSHandle *)handle firstBytes:(NSData *)header name:(NSString *)name error:(XADError *)errorptr;
+(XADArchiveParser *)archiveParserForHandle:(CSHandle *)handle firstBytes:(NSData *)header resourceFork:(XADResourceFork *)fork name:(NSString *)name;
+(XADArchiveParser *)archiveParserForHandle:(CSHandle *)handle firstBytes:(NSData *)header resourceFork:(XADResourceFork *)fork name:(NSString *)name error:(XADError *)errorptr;
+(XADArchiveParser *)archiveParserForPath:(NSString *)filename;
+(XADArchiveParser *)archiveParserForPath:(NSString *)filename error:(XADError *)errorptr;
+(XADArchiveParser *)archiveParserForEntryWithDictionary:(NSDictionary *)entry archiveParser:(XADArchiveParser *)parser wantChecksum:(BOOL)checksum;
+(XADArchiveParser *)archiveParserForEntryWithDictionary:(NSDictionary *)entry archiveParser:(XADArchiveParser *)parser wantChecksum:(BOOL)checksum error:(XADError *)errorptr;
+(XADArchiveParser *)archiveParserForEntryWithDictionary:(NSDictionary *)entry resourceForkDictionary:(NSDictionary *)forkentry archiveParser:(XADArchiveParser *)parser wantChecksum:(BOOL)checksum;
+(XADArchiveParser *)archiveParserForEntryWithDictionary:(NSDictionary *)entry resourceForkDictionary:(NSDictionary *)forkentry archiveParser:(XADArchiveParser *)parser wantChecksum:(BOOL)checksum error:(XADError *)errorptr;
 
-(id)init;
-(void)dealloc;

-(CSHandle *)handle;
-(void)setHandle:(CSHandle *)newhandle;
-(XADResourceFork *)resourceFork;
-(void)setResourceFork:(XADResourceFork *)newfork;
-(NSString *)name;
-(void)setName:(NSString *)newname;
-(NSString *)filename;
-(void)setFilename:(NSString *)filename;
-(NSArray *)allFilenames;
-(void)setAllFilenames:(NSArray *)newnames;

-(id)delegate;
-(void)setDelegate:(id)newdelegate;

-(NSDictionary *)properties;
-(NSString *)currentFilename;

-(BOOL)isEncrypted;
-(NSString *)password;
-(BOOL)hasPassword;
-(void)setPassword:(NSString *)newpassword;

-(NSString *)encodingName;
-(float)encodingConfidence;
-(void)setEncodingName:(NSString *)encodingname;
-(BOOL)caresAboutPasswordEncoding;
-(NSString *)passwordEncodingName;
-(void)setPasswordEncodingName:(NSString *)encodingname;
-(XADStringSource *)stringSource;

-(XADString *)linkDestinationForDictionary:(NSDictionary *)dict;
-(XADString *)linkDestinationForDictionary:(NSDictionary *)dict error:(XADError *)errorptr;
-(NSDictionary *)extendedAttributesForDictionary:(NSDictionary *)dict;
-(NSData *)finderInfoForDictionary:(NSDictionary *)dict;

-(BOOL)wasStopped;

-(BOOL)hasChecksum;
-(BOOL)testChecksum;
-(XADError)testChecksumWithoutExceptions;



// Internal functions

+(NSArray *)scanForVolumesWithFilename:(NSString *)filename
regex:(XADRegex *)regex firstFileExtension:(NSString *)firstext;

-(BOOL)shouldKeepParsing;

-(CSHandle *)handleAtDataOffsetForDictionary:(NSDictionary *)dict;
-(XADSkipHandle *)skipHandle;
-(CSHandle *)zeroLengthHandleWithChecksum:(BOOL)checksum;
-(CSHandle *)subHandleFromSolidStreamForEntryWithDictionary:(NSDictionary *)dict;

-(NSArray *)volumes;
-(off_t)offsetForVolume:(int)disk offset:(off_t)offset;

-(void)setObject:(id)object forPropertyKey:(NSString *)key;
-(void)addPropertiesFromDictionary:(NSDictionary *)dict;
-(void)setIsMacArchive:(BOOL)ismac;

-(void)addEntryWithDictionary:(NSMutableDictionary *)dict;
-(void)addEntryWithDictionary:(NSMutableDictionary *)dict retainPosition:(BOOL)retainpos;

-(XADString *)XADStringWithString:(NSString *)string;
-(XADString *)XADStringWithData:(NSData *)data;
-(XADString *)XADStringWithData:(NSData *)data encodingName:(NSString *)encoding;
-(XADString *)XADStringWithBytes:(const void *)bytes length:(int)length;
-(XADString *)XADStringWithBytes:(const void *)bytes length:(int)length encodingName:(NSString *)encoding;
-(XADString *)XADStringWithCString:(const char *)cstring;
-(XADString *)XADStringWithCString:(const char *)cstring encodingName:(NSString *)encoding;

-(XADPath *)XADPath;
-(XADPath *)XADPathWithString:(NSString *)string;
-(XADPath *)XADPathWithUnseparatedString:(NSString *)string;
-(XADPath *)XADPathWithData:(NSData *)data separators:(const char *)separators;
-(XADPath *)XADPathWithData:(NSData *)data encodingName:(NSString *)encoding separators:(const char *)separators;
-(XADPath *)XADPathWithBytes:(const void *)bytes length:(int)length separators:(const char *)separators;
-(XADPath *)XADPathWithBytes:(const void *)bytes length:(int)length encodingName:(NSString *)encoding separators:(const char *)separators;
-(XADPath *)XADPathWithCString:(const char *)cstring separators:(const char *)separators;
-(XADPath *)XADPathWithCString:(const char *)cstring encodingName:(NSString *)encoding separators:(const char *)separators;

-(NSData *)encodedPassword;
-(const char *)encodedCStringPassword;

-(void)reportInterestingFileWithReason:(NSString *)reason,...;



// Subclasses implement these:

+(int)requiredHeaderSize;
+(BOOL)recognizeFileWithHandle:(CSHandle *)handle firstBytes:(NSData *)data
name:(NSString *)name;
+(BOOL)recognizeFileWithHandle:(CSHandle *)handle firstBytes:(NSData *)data
name:(NSString *)name propertiesToAdd:(NSMutableDictionary *)props;
+(BOOL)recognizeFileWithHandle:(CSHandle *)handle firstBytes:(NSData *)data
resourceFork:(XADResourceFork *)fork name:(NSString *)name propertiesToAdd:(NSMutableDictionary *)props;
+(NSArray *)volumesForHandle:(CSHandle *)handle firstBytes:(NSData *)data
name:(NSString *)name;

-(void)parse;
-(CSHandle *)handleForEntryWithDictionary:(NSDictionary *)dict wantChecksum:(BOOL)checksum;
-(NSString *)formatName;

-(CSHandle *)handleForSolidStreamWithObject:(id)obj wantChecksum:(BOOL)checksum;

// Exception-free wrappers for subclass methods:
// parseWithoutExceptions will in addition return XADBreakError if the delegate
// requested parsing to stop.

-(XADError)parseWithoutExceptions;
-(CSHandle *)handleForEntryWithDictionary:(NSDictionary *)dict wantChecksum:(BOOL)checksum error:(XADError *)errorptr;

@end

@interface NSObject (XADArchiveParserDelegate)

-(void)archiveParser:(XADArchiveParser *)parser foundEntryWithDictionary:(NSDictionary *)dict;
-(BOOL)archiveParsingShouldStop:(XADArchiveParser *)parser;
-(void)archiveParserNeedsPassword:(XADArchiveParser *)parser;
-(void)archiveParser:(XADArchiveParser *)parser findsFileInterestingForReason:(NSString *)reason;

@end

NSMutableArray *XADSortVolumes(NSMutableArray *volumes,NSString *firstfileextension);
