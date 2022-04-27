#include <bits/stdc++.h>
using namespace std;

template <class T, class E>
class MyResult
{
public:
    T val;
    char *err;
    MyResult() {}
    MyResult(T val, E err) : val(val), err(err) {}
};
template <typename T>
class Test
{
public:
    T test_heapcheck(void)
    {

        string cmd = "LD_PRELOAD=../build/heapcheck.so ./heapoverflow 13 `perl -e 'print \"a\" x 0x100'`";
        FILE *fp = popen(cmd.c_str(), "r");
        MyResult r = new MyResult(nullptr, nullptr);
        if (fp == NULL)
        {
            r = MyResult(nullptr, "can't run command,because peopen error");
            return r;
        }
        char buffer[101];
        while (!feof(fp))
        {
            if (fgets(buffer, 100, fp) == NULL)
                break;
            string str = buffer;
            if (str.find("Bad idea! Aborting strcpy to prevent heap overflow") != string::npos)
            {
                cout << "[+] test heapchck success" << endl;
                r = MyResult(true, nullptr);
            }
        }
        pclose(fp);
        delete fp;
        r = MyResult(nullptr, "heapcheack.so test failed");
        return r;
    };
    bool test_elfinject()
    {
        return false;
    }
    bool test_loader()
    {
        return false;
    }
    void all_test()
    {
        MyResult r = test_heapcheck();
        if (r.val == true && r.err == nullptr)
        {
            cout << "[+] ALL TEST SUCESS" << endl;
        }
    }
};

int main()
{
    Test t = new Test();
    t.all_test();
    return 0;
}
