//
//  main.m
//  Algo
//
//  Created by Tuong Hoang on 3/12/18.
//  Copyright © 2018 tonyhoang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <stdio.h>

@interface Node : NSObject {
}

@property (nonatomic, strong) NSMutableArray* children;
@property (nonatomic, copy) NSString* name;
@property (nonatomic, assign) NSInteger level;

@end

static const NSInteger SPACE_PADDING_PER_LEVEL = 4;

@implementation Node

- (id)initWithName:(NSString*)name {
    if (self = [super init]) {
        self.name = name;
        self.level = 0;
    }
    
    return self;
}

- (id)initWithNames:(NSString*)names {
    if (self = [super init]) {
        NSArray* nameArr = [names componentsSeparatedByString: @","];
        
        if (nameArr.count > 1) {
            self.name = nameArr[0];
            self.level = 0;
            
            self.children = [NSMutableArray new];
            for (int i = 1; i < nameArr.count; i ++) {
                Node* child = [[Node alloc] initWithName: nameArr[i]];
                child.level = 1;
                [self.children addObject: child];
            }
        }
    }
    
    return self;
}

- (BOOL)isChildNodeOf:(Node*)node {
    for (Node* child in node.children) {
        if ([self.name isEqualToString: child.name]
            || [self isChildNodeOf: child]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)updateNodeLevelFromNode:(Node*)node {
    self.level = node.level;
    
    for (Node* child in self.children) {
        [child increaseNodeLevelFromNode:node];
    }
}

- (void)increaseNodeLevelFromNode:(Node*)node {
    self.level += node.level;
    
    for (Node* child in self.children) {
        [child increaseNodeLevelFromNode:node];
    }
}


- (void)mergeFromChildNode:(Node*)node {
    for (int i = 0; i < self.children.count; i ++) {
        Node* child = self.children[i];
        
        if ([child.name isEqualToString: node.name]) {
            [node updateNodeLevelFromNode: child];
            [self.children replaceObjectAtIndex:i withObject:node];
        } else {
            [child mergeFromChildNode: node];
        }
    }
}

- (void)print {
    printf("\n%*s", (int) (SPACE_PADDING_PER_LEVEL*self.level), [self.name UTF8String]);
    
    for (Node* child in self.children) {
        [child print];
    }
}

@end

/*
 
 B2,C3,D4
 G7,H8
 A1,B2,G7
 D4,E5,F6
 //B2,I9
 
 A1
    B2
        C3
        D4
            E5
            F6
        I9
    G7
        H8
 */

int main (int argc, const char * argv[])
{
    @autoreleasepool {
        NSArray* inputs = @[
                            @"B2,C3,D4",
                            @"A1,B2,G7",
                            @"D4,E5,F6",
                            @"G7,H8",
                            // @"B2,I9"
                            ];
        
        // Read, parse the input and create an array of nodes
        NSMutableArray* nodes = [NSMutableArray new];
        for (NSString* input in inputs) {
            Node* node = [[Node alloc] initWithNames: input];
            [nodes addObject: node];
        }
        
        // Merge nodes into a single node
        int i = 1;
        while (nodes.count > 1) {
            Node* firstNode = nodes[0];
            if (i < nodes.count && [firstNode isChildNodeOf: nodes[i]]) {
                [nodes[i] mergeFromChildNode: firstNode];
                [nodes removeObjectAtIndex: 0];
                i = 1;
            } else if (i < nodes.count && [nodes[i] isChildNodeOf:firstNode]) {
                [firstNode mergeFromChildNode: nodes[i]];
                [nodes removeObjectAtIndex: i];
                i = 1;
            } else {
                i ++;
            }
        }
        
        // Output the result
        [nodes[0] print];
    }
}

