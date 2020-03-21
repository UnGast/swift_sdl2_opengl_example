#include <iostream>
#include <string>
#include <typeinfo>

int main() {
    int test = 30;
    const std::type_info& ti1 = typeid(10);
    const std::type_info& ti2 = typeid(30);
    std::cout << "WOW" << std::endl;
    std::cout << "HAS TYPE: " << typeid(sizeof(float)).name() << std::endl;
}