#include <stdio.h>
#include <string.h>

int min(int x, int y) {return x<y?x:y;}

int m(char *s1, int i, char *s2, int j) {return s1[i-1]!=s2[j-1];}

char *String1, *String2;

int D(int i, int j)
{
    if(i==0&&j==0) return 0;
    if(i==0&&j) return j;
    if(i&&j==0) return i;

    int d1=D(i, j-1)+1,
        d2=D(i-1, j)+1,
        d3=D(i-1, j-1)+m(String1, i, String2, j);
    return min(min(d1, d2), d3);

/*
distance(A, B)=D(|A|, |B|)

D(i, j) = 0, if i=0, j=0
        = i, if j=0, i>0
        = j, if i=0, j>0
        = min(D(i, j-1)+1, D(i-1, j)+1, D(i-1, j-1)+m(A_i, B_j)), if j>0, i>0

m(a, b) = 0, if a=b
        = 1, if a!=b

min(x, y, z)=min(min(x, y), z)

Example:
 distance("polynomial", "exponential")=6.
*/
}

int main(int c, char **a)
{
    if(c<3)
    {
        printf("usage: %s <string_1> <string_2>", a[0]);
        return 0;
    }
    String1=a[1]; String2=a[2];
    int Distance=D(strlen(String1), strlen(String2));
    printf("distance=%d\n", Distance);
    return 0;
}
