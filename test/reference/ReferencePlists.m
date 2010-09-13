/* ReferencePlists.m
 *
 * Generates both XML and binary property lists using the Mac OS X Foundation
 * framework, for testing of third-party plist libraries.
 *
 * Build with: gcc -Os -Wall -std=c99 ReferencePlists.m -o ReferencePlists -framework Foundation
 *
 * After running, pipe each .xml file through "xmllint --noblanks" to remove
 * extraneous whitespace.
 *
 * Requires Mac OS X 10.6 or later.
 */

#import <Foundation/Foundation.h>

void WritePlist(id plist, NSPropertyListFormat format, NSString *filename)
{
    NSError *error;
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:plist
                                                              format:format
                                                             options:0
                                                               error:&error];
    if (data != nil)
    {
        if (![data writeToFile:filename options:0 error:&error])
        {
            NSLog(@"Error writing serialized data to %@", filename);
            if (error != nil)
            {
                NSLog(@"NSError = %@", [error localizedDescription]);
            }
        }
    }
    else
    {
        NSLog(@"Error serializing plist to %@.", filename);
        if (error != nil)
        {
            NSLog(@"NSError = %@", [error localizedDescription]);
        }
    }
}

void WriteBothPlistFormats(id plist, NSString *filename)
{
    WritePlist(plist, NSPropertyListBinaryFormat_v1_0, [NSString stringWithFormat:@"%@.plist", filename]);
    WritePlist(plist, NSPropertyListXMLFormat_v1_0, [NSString stringWithFormat:@"%@.xml", filename]);
}

int main(int argc, const char * argv[])
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

    // Boolean
    WriteBothPlistFormats([NSNumber numberWithBool:YES], @"boolean_true");
    WriteBothPlistFormats([NSNumber numberWithBool:NO], @"boolean_false");

    // Integers
    WriteBothPlistFormats([NSNumber numberWithUnsignedInt:1U], @"int_1_byte");
    WriteBothPlistFormats([NSNumber numberWithUnsignedShort:256U], @"int_2_bytes");
    WriteBothPlistFormats([NSNumber numberWithUnsignedInt:65536U], @"int_4_bytes");
    WriteBothPlistFormats([NSNumber numberWithUnsignedLongLong:(uint64_t)4294967296ULL], @"int_8_bytes");
    WriteBothPlistFormats([NSNumber numberWithInt:-1], @"int_signed");
    
    // Floating point numbers
    WriteBothPlistFormats([NSNumber numberWithFloat:1.5], @"real_float");
    WriteBothPlistFormats([NSNumber numberWithDouble:1.5], @"real_double");
    
    // Dates
    WriteBothPlistFormats([NSDate dateWithTimeIntervalSince1970:0], @"date_epoch");
    WriteBothPlistFormats([NSDate dateWithString:@"1900-01-01 12:00:00 +0000"], @"date_1900");
    
    // Arbitrary data
    WriteBothPlistFormats([NSData dataWithBytes:"data" length:4], @"data_short");
    WriteBothPlistFormats([NSData dataWithBytes:"datadatadatadata" length:16], @"data_long_1_byte");
    NSMutableData *data = [[NSMutableData alloc] initWithCapacity:512];
    for (int i = 0; i < 512; i += 4)
    {
        [data appendBytes:"data" length:4];
    }
    WriteBothPlistFormats(data, @"data_long_2_bytes");
    for (int i = 0; i < 65536 - 512; i += 4)
    {
        [data appendBytes:"data" length:4];
    }
    WriteBothPlistFormats(data, @"data_long_4_bytes");
    [data release];
    
    // Strings
    WriteBothPlistFormats([NSString stringWithCString:"data" encoding:NSASCIIStringEncoding], @"string_ascii_short");
    WriteBothPlistFormats([NSString stringWithCString:"datadatadatadata" encoding:NSASCIIStringEncoding], @"string_ascii_long");
    WriteBothPlistFormats([NSString stringWithUTF8String:"UTF-8 \u263C"], @"string_utf8_short");
    WriteBothPlistFormats([NSString stringWithUTF8String:"long UTF-8 data with a 4-byte glyph \U00010102"], @"string_utf8_long");
    
    // Array
    WriteBothPlistFormats([NSArray arrayWithObject:@"object"], @"array");
    
    // Dictionary
    WriteBothPlistFormats([NSDictionary dictionaryWithObject:@"value" forKey:@"key"], @"dictionary");
    
    // Multiple objects, each object offset is 1 bytes
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < 20; i++)
    {
        [array addObject:[NSString stringWithFormat:@"%d", i]];
    }
    WriteBothPlistFormats(array, @"offsets_1_byte");

    // 300+ byte strings make the offsets 2 bytes each
    NSMutableString *string = [NSMutableString string];
    for (int i = 0; i < 30; i++)
    {
        [string appendString:@"1234567890"];
    }
    array = [NSMutableArray arrayWithObjects:
             [string stringByAppendingString:@"-0"],
             [string stringByAppendingString:@"-1"],
             nil];
    WriteBothPlistFormats(array, @"offsets_2_bytes");
    
    /* 220 of those strings is >64 KB, which will push the object offsets to
     * 4 bytes. */
    for (int i = 2; i < 220; i++)
    {
        [array addObject:[string stringByAppendingFormat:@"-%d", i]];
    }
    WriteBothPlistFormats(array, @"offsets_4_bytes");
    
    [pool drain];
    return 0;
}
