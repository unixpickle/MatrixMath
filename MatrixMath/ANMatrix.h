//
//  ANMatrix.h
//  MatrixMath
//
//  Created by Alex Nichol on 1/23/13.
//  Copyright (c) 2013 Alex Nichol. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ANMatrix : NSObject <NSCopying> {
    float ** matrixData;
    int rowCount, columnCount;
}

+ (ANMatrix *)identityMatrix:(int)size;
+ (ANMatrix *)rowExchangeMatrixOfSize:(int)size switchRow:(int)row1 withRow:(int)row2;

- (id)initWithString:(NSString *)string;
- (id)initWithRows:(int)rows columns:(int)columns;
- (int)rowCount;
- (int)columnCount;

- (float)itemAtRow:(int)row column:(int)column;
- (void)setItem:(float)item atRow:(int)row column:(int)column;
- (void)setRows:(int)newRowCount columns:(int)newColumnCount;

- (ANMatrix *)transpose;
- (ANMatrix *)scale:(float)scalar;
- (ANMatrix *)add:(ANMatrix *)anotherMatrix;

- (ANMatrix *)multiply:(ANMatrix *)anotherMatrix;
- (ANMatrix *)rowEchelonTransform:(int *)rank;
- (ANMatrix *)reducedRowEchelonTransform:(int *)rank;

- (ANMatrix *)nullspaceBasis;

- (ANMatrix *)specialSolution:(ANMatrix *)answer;

@end
