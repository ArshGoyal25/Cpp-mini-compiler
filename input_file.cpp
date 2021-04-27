#include<iostream>
int main()
{
    int a = 5;
    int b = 4;
    int c = 2;
    b = b*4;
    int d = 1;
    int e = a * b / c+d;
    while(c<10){
        c = c+1;
        d = d -c;
    }
    if(c > 30){
        b = 100;
    }
    else
        b = 200;

	switch(d){
        case 1 : a = a + b ;
            break;
        case 2 : c = a + b;
            break;
        case 5 : d = a + b;
            break;
        default: b = a + b;
            break;
    }
}