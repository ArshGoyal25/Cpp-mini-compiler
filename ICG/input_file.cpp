#include<iostream>
int main()
{
    int a=1;
    int c=5;
    int b=4,d=5;
    switch(d){
        case 1 : a = a +b;
            break;
        case 2 : c = a+b;
        case 3 : d = a +b;
        default: b = a+b;
    }
	a=5;
	int c=b;

    float z1=4.2,z2=4.8;

	switch(d){
        case 1 : a = a +b;
            break;
        case 2 : c = a+b;
            break;
        case 3 : d = a +b;
            break;
        default: b = a+b;
        break;
    }
	// while(c<a){
	// 	b = b+2;
    //     c = 10;
    //     if(b == 5)
    //     {
    //         break;
    //     }
	// }

	// if(c<b)
	// {
	// 	if(a<b)
    //     {
    //         a = 10;
    //         //cout<<a;
    //     }
	// }
    // int d = a/b+c;
}