#include<iostream>
int main()
{
    int a = 5, b = 4, c = 2;
    b = b*4;
    int d = 2;
    float e = a * b / c + d;
    while(b<10){
        a = b-1;
    }
    float z = 4.2;
    if(z > 4)
        b = 100;
    else
        b = 200;
	switch(d){
        case 1 : d = a + b ;
            break;
        case 2 : d = a + c;
            break;
        default: d = 10;
    }
    return d;
}