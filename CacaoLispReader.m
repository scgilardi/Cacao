//
//  CacaoLispReader.m
//  Cacao
//
//    Copyright 2010, Joubert Nel. All rights reserved.
//
//    Redistribution and use in source and binary forms, with or without modification, are
//    permitted provided that the following conditions are met:
//
//    1. Redistributions of source code must retain the above copyright notice, this list of
//    conditions and the following disclaimer.
//
//    2. Redistributions in binary form must reproduce the above copyright notice, this list
//    of conditions and the following disclaimer in the documentation and/or other materials
//    provided with the distribution.
//
//    THIS SOFTWARE IS PROVIDED BY JOUBERT NEL "AS IS'' AND ANY EXPRESS OR IMPLIED
//    WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//    FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL JOUBERT NEL OR
//    CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//    CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//    SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//    ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//    NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//    ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//    The views and conclusions contained in the software and documentation are those of the
//    authors and should not be interpreted as representing official policies, either expressed
//    or implied, of Joubert Nel.

#import "CacaoLispReader.h"
#import "BigInteger.h"
#import "BigDecimal.h"
#import "GMPRational.h"
#import "RegexKitLite.h"

// Reader Macros
#import "CacaoReaderMacroInvokers.h"


static NSDictionary * macroDispatch = nil;
static NSCharacterSet * additionalWhitespaceCharacterSet = nil;


@implementation CacaoLispReader


+ (void)initialize
{            
    macroDispatch = [NSDictionary dictionaryWithObjectsAndKeys:
                     cacaoStringReaderMacro,                @"\"",
                     cacaoListReaderMacro,                  @"(",
                     cacaoUnmatchedDelimiterReaderMacro,    @")",    
                     nil];
    
    additionalWhitespaceCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@","];
}

+ (BOOL)isWhiteSpace:(unichar)theCharacter
{
    if ([[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:theCharacter] ||
        [additionalWhitespaceCharacterSet characterIsMember:theCharacter])
        return YES;
    else
        return NO;
}

+ (id)macroDispatcherForChar:(int)macroChar
{
    unichar theCharArray[1];
    theCharArray[0] = macroChar;
    NSString * theCharAsString = [NSString stringWithCharacters:theCharArray length:1];
    id macroDispatcher = nil;
    macroDispatcher = [macroDispatch objectForKey:theCharAsString];
    return macroDispatcher;
}

+ (BOOL)isMacro:(int)theChar
{
    return [CacaoLispReader macroDispatcherForChar:theChar] != nil;
}

+ (id)matchSymbol:(NSString *)token
{
    NSRange     searchRange     = NSMakeRange(0, [token length]);
    NSRange     matchedRange;
    NSError     *error          = nil;
    
    NSArray * matches = nil;
    matches = [token captureComponentsMatchedByRegex:symbolPat];
    if (matches != nil)
    {
        NSString * ns = nil;
        NSString * name = nil;
        if ([matches count] == 1)
        {
            
        }
    }

    
    //matchedRange = [token rangeOfRegex:symbolPat options:RKLNoOptions inRange:searchRange capture:0 error:&error];
//    if (matchedRange.length == searchRange.length)
//    {
//        
//    }
    
    return nil;
}

+ (id)interpretToken:(NSString *)token
{
    if ([token isEqualToString:@"nil"])
        return nil;
    else if ([token isEqualToString:@"YES"])
    {
        BOOL yes = YES;
        return [NSValue valueWithBytes:&yes objCType:@encode(BOOL)];
    }
    else if ([token isEqualToString:@"NO"])
    {
        BOOL no = NO;
        return [NSValue valueWithBytes:&no objCType:@encode(BOOL)];
    }
    
    id ret = nil;
    ret = [CacaoLispReader matchSymbol:token];
    if (ret != nil)
        return ret;
    
    @throw [NSException exceptionWithName:@"InvalidTokenException"
                                   reason:[NSString stringWithFormat:@"Invalid token: %@",token]
                                 userInfo:nil];
        
}

+ (BOOL)isTerminatingMacro:(int)ch
{
    return ((ch != '#') && [CacaoLispReader isMacro:ch]);
}

+ (NSString *)readTokenFrom:(PushbackReader *)reader firstCharacter:(int)ch
{
    NSMutableString * token = [NSMutableString string];
    unichar charArray[1];
    charArray[0] = ch;
    [token appendString:[NSString stringWithCharacters:charArray length:1]];
    while (YES) {
        int nextChar = [reader read];
        if (nextChar == -1 || [CacaoLispReader isWhiteSpace:nextChar] || [CacaoLispReader isTerminatingMacro:nextChar])
        {
            [reader unreadSoThatNextCharIs:nextChar];
            return token;
        }
        charArray[0] = nextChar;
        [token appendString:[NSString stringWithCharacters:charArray length:1]];
    }
    
}




#pragma mark Read numbers

+ (NSObject *)matchNumber:(NSString *)theString
{
	// Use regex instead of Cocoa's NSScanner, because the latter
	// has numeric semantics different from what we want
	
	NSRange		searchRange		= NSMakeRange(0, [theString length]);
	NSRange		matchedRange;
	NSError		*error			= nil;
	
    
	
	matchedRange = [theString rangeOfRegex:intPat options:RKLNoOptions inRange:searchRange capture:0 error:&error];
	if (matchedRange.length == searchRange.length)
	{
		if ([theString stringByMatching:intPat capture:2] != nil)
            return [NSNumber numberWithInteger:0];
		
        NSString * firstCharOfNumber = [theString stringByMatching:intPat capture:1];
		BOOL negate = [firstCharOfNumber isEqualToString:@"-"];
		NSString *n;
		int base = 10;
		if ((n = [theString stringByMatching:intPat capture:3]) != nil)
			base = 10;
		else if ((n = [theString stringByMatching:intPat capture:4]) != nil)
			base = 16;
		else if ((n = [theString stringByMatching:intPat capture:5]) != nil)
			base = 8;
		else if ((n = [theString stringByMatching:intPat capture:7]) != nil)
			base = [[theString stringByMatching:intPat capture:6] intValue];		
		if (n == nil)
			return nil;
		BigInteger *bn = [BigInteger bigIntegerWithValue:n base:base];
		if (negate) bn = [bn negate];
		return bn;			
	}
    
    matchedRange = [theString rangeOfRegex:ratioPat options:RKLNoOptions inRange:searchRange capture:0 error:&error];
	if (matchedRange.location != NSNotFound)
	{
		NSString *numerator = [theString stringByMatching:ratioPat capture:1];
		NSString *denominator = [theString stringByMatching:ratioPat capture:2];
		GMPRational *ratio = [GMPRational rationalWithValue:[numerator stringByAppendingFormat:@"/%@", denominator]];
		return ratio;
	}
	
	
	matchedRange = [theString rangeOfRegex:floatPat options:RKLNoOptions inRange:searchRange capture:0 error:&error];
	if (matchedRange.location != NSNotFound)
	{
		if ([[theString substringFromIndex:[theString length] -1] isEqualToString:@"M"])
			return [BigDecimal bigDecimalWithValue:theString];
		else
			return [NSNumber numberWithDouble:[theString doubleValue]];
	}
	
	return nil;
}


+ (id)readNumberFrom:(PushbackReader *)reader firstDigit:(int)digit
{
    NSMutableString * numberString = [NSMutableString string];
    unichar charArray[1];
    charArray[0] = digit;
    [numberString appendString:[NSString stringWithCharacters:charArray length:1]];
    
    while (YES) {
        int ch = [reader read];
        if (ch == -1 || [CacaoLispReader isWhiteSpace:ch] || [CacaoLispReader isMacro:ch])
        {
            [reader unreadSoThatNextCharIs:ch];
            break;
        }
        
        charArray[0] = ch;
        [numberString appendString:[NSString stringWithCharacters:charArray length:1]];
    }
    
    NSObject * theNumber = nil;
    theNumber = [CacaoLispReader matchNumber:numberString];
    if (theNumber == nil)
        @throw [NSException exceptionWithName:@"NumberFormatException" 
                                       reason:[NSString stringWithFormat:@"Invalid number: %s", numberString]
                                     userInfo:nil];
    return theNumber;
}


#pragma mark Entry point

+ (id)readFrom:(PushbackReader *)reader eofValue:(NSObject *)eofValue
{
    do {        
        int ch = [reader read];
        
        while ([[NSCharacterSet whitespaceCharacterSet] characterIsMember:ch])
            ch = [reader read];
        
        if (ch == -1)
            return eofValue;
        
        if ([[NSCharacterSet decimalDigitCharacterSet] characterIsMember:ch]) {
            id number = [CacaoLispReader readNumberFrom:reader firstDigit:ch];
            return number;
        }
        
        ReaderMacro macroDispatcher = [CacaoLispReader macroDispatcherForChar:ch];        
        if (macroDispatcher != nil) {
            NSObject * ret = macroDispatcher(reader, ch);           
            if (ret == reader)
                continue;
            return ret;
        }      
        
        if (ch == '+' || ch == '-')
        {
            int ch2 = [reader read];
            if ([[NSCharacterSet decimalDigitCharacterSet] characterIsMember:ch2])
            {
                id number = [CacaoLispReader readNumberFrom:reader firstDigit:ch];
                return number;
            }
        }
        
        NSString * token = [CacaoLispReader readTokenFrom:reader firstCharacter:ch];
        return [CacaoLispReader interpretToken:token];
        
    } while (YES);
}


#pragma mark Support

+ (NSArray *)readListDelimitedWith:(char)delim from:(PushbackReader *)reader
{
    NSMutableArray * theList = [NSMutableArray array];
    while (YES) {
        int ch = [reader read];
        while([CacaoLispReader isWhiteSpace:ch])
            ch = [reader read];
        
        if (ch == -1)
            @throw [NSException exceptionWithName:@"EOFException"
                                           reason:@"EOF while reading"
                                         userInfo:nil];
        if (ch == delim)
            break;
        
        ReaderMacro macroDispatcher = [CacaoLispReader macroDispatcherForChar:ch];
        if (macroDispatcher != nil)
        {
            id macroRet = macroDispatcher(reader, ch);

            // no op macros return the reader
            if (macroRet != reader)
                    [theList addObject:macroRet];                      
        }
        else {
            [reader unreadSoThatNextCharIs:ch];
            id nextItem = [CacaoLispReader readFrom:reader eofValue:nil];
            if (nextItem != reader)
                [theList addObject:nextItem];
        }
        
    }
    
    return [NSArray arrayWithArray:theList];
    
}

@end
