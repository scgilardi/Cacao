//
//  BigInteger.h
//  Cacao
//
//    Copyright 2010, 2011, Joubert Nel. All rights reserved.
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

#import <Foundation/Foundation.h>
#import "CacaoReadable.h"
#import "gmp.h"


typedef enum {
	SMALLER=-1, 
	EQUAL=0, 
	LARGER=1
} BigIntegerComparison;



@interface BigInteger: NSObject <NSCopying, CacaoReadable> {
    NSData *    mpzData;
    size_t      mpzDataWordCount;
	int         base;
    BOOL        isNegative;
}

@property (nonatomic, retain) NSData * mpzData;
@property (nonatomic, assign) size_t mpzDataWordCount;
@property (nonatomic, assign) int base;
@property (nonatomic, assign) BOOL isNegative;


+ (BigInteger *)bigIntegerWithMPZ:(mpz_t)mpz base:(int)theBase;
+ (BigInteger *)bigIntegerWithMPZ:(mpz_t)mpz;
+ (BigInteger *)bigIntegerWithValue:(NSString *)theValue base:(int)theBase;
+ (BigInteger *)bigIntegerWithValue:(NSString *)theValue;
+ (BigInteger *)bigIntegerWithUIntValue:(NSUInteger)theValue;

- (id)copyWithZone:(NSZone *)zone;

- (void)printToTextView:(NSTextView *)target;
- (NSString *)readableValue;
- (NSString *)description;

- (BOOL)isEqual:(id)object;
- (BOOL)isLessThan:(BigInteger *)number;
- (BOOL)isGreaterThan:(BigInteger *)number;
- (NSUInteger)unsignedIntegerValue;

- (BigInteger *)add:(BigInteger *)anotherNumber;
- (BigInteger *)subtract:(BigInteger *)anotherNumber;
- (BigInteger *)multiply:(BigInteger *)anotherNumber;
- (BigInteger *)divide:(BigInteger *)divisor;
- (BigInteger *)increment;


@end
