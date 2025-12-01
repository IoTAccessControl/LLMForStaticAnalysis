#include <stdio.h>
#include <stdbool.h>
const char NUL = '\0';
bool ope_line()
{
    char oline[101];
    const char letter[6][5] = {"abcde", "fghij", "klmno", "pqrst", "uvwxy", "z.?! "};
    int c = getc(stdin);
    if (c == EOF)
        return false;
    if (c == '\n')
        return true;
    bool b_na = false;
    int ix = 0;
    while (c != '\n' && c != EOF)
    {
        int s = c - '1';

        int fit[100], ic, x, t, fc, p, q, r;
        char ft[100];
        ic = 1;
        for (t = 0; t < 100; t++)
        {
            fit[t] = 0;
        }
        while (ic < fc)
        {
            if (ft[ic] == 'P')
            {
                fit[ic] = p;
            }
            if (ft[ic] == 'Q')
            {
                fit[ic] = q;
            }
            if (ft[ic] == 'R')
            {
                fit[ic] = r;
            }
            if (ft[ic] == '0')
            {
                fit[ic] = 0;
            }
            if (ft[ic] == '1')
            {
                fit[ic] = 1;
            }
            if (ft[ic] == '2')
            {
                fit[ic] = 2;
            }
            if (ft[ic] == '+')
            {
                fit[ic] = 3;
            }
            if (ft[ic] == '-')
            {
                fit[ic] = 4;
            }
            if (ft[ic] == '*')
            {
                fit[ic] = 5;
            }
            ic++;
        }
        ic--;
        x = 1;
        while (x < ic)
        {
            if (fit[x] == 3)
            {
                if (fit[x - 1] == 0 && fit[x - 2] == 0)
                {
                    fit[x - 2] = 0;
                }
                else if (fit[x - 1] == 2 || fit[x - 2] == 2)
                {
                    fit[x - 2] = 2;
                }
                else
                {
                    fit[x - 2] = 1;
                }
                ic -= 2;
                for (t = x - 1; t <= ic; t++)
                {
                    fit[t] = fit[t + 2];
                }
                x -= 2;
            }
            if (fit[x] == 4)
            {
                fit[x - 1] = 2 - fit[x - 1];
                ic--;
                for (t = x; t <= ic; t++)
                {
                    fit[t] = fit[t + 1];
                }
                x--;
            }
            if (fit[x] == 5)
            {
                if (fit[x - 1] == 0 || fit[x - 2] == 0)
                {
                    fit[x - 2] = 0;
                }
                else if (fit[x - 1] == 2 && fit[x - 2] == 2)
                {
                    fit[x - 2] = 2;
                }
                else
                {
                    fit[x - 2] = 1;
                }
                ic -= 2;
                for (t = x - 1; t <= ic; t++)
                {
                    fit[t] = fit[t + 2];
                }
                x -= 2;
            }
            x++;
        }
        int a[5][20];
        int b[5][10];
        int n, m;
        int point;
        scanf("%d", &n);
        while (n)
        {
            point = 0;
            for (int i = 0; i < 20; i++)
            {
                for (int j = 0; j < 5; j++)
                {
                    a[j][i] = 0;
                }
            }
            for (int i = 0; i < n; i++)
            {
                for (int j = 0; j < 5; j++)
                {
                    scanf("%d", &a[j][n - 1 - i]);
                }
            }
            m = 11;
            while (m > 0)
            {
                for (int i = 0; i < n; i++)
                {
                    for (int j = 0; j < 5; j++)
                    {
                        b[j][i] = 0;
                    }
                }
                for (int i = 0; i < n; i++)
                {
                    if (a[0][i] == a[1][i] && a[1][i] == a[2][i] && a[0][i] != 0)
                    {
                        if (a[2][i] == a[3][i])
                        {
                            if (a[3][i] == a[4][i])
                            {
                                point += a[0][i] * 5;
                                for (int j = 0; j < 5; j++)
                                {
                                    b[j][i] = 1;
                                }
                            }
                            else
                            {
                                point += a[0][i] * 4;
                                for (int j = 0; j < 4; j++)
                                {
                                    b[j][i] = 1;
                                }
                            }
                        }
                        else
                        {
                            point += a[0][i] * 3;
                            for (int j = 0; j < 3; j++)
                            {
                                b[j][i] = 1;
                            }
                        }
                    }
                    else if (a[1][i] == a[2][i] && a[2][i] == a[3][i] && a[1][i] != 0)
                    {
                        if (a[3][i] == a[4][i])
                        {
                            point += a[1][i] * 4;
                            for (int j = 1; j < 5; j++)
                            {
                                b[j][i] = 1;
                            }
                        }
                        else
                        {
                            point += a[1][i] * 3;
                            for (int j = 1; j < 4; j++)
                            {
                                b[j][i] = 1;
                            }
                        }
                    }
                    else if (a[2][i] == a[3][i] && a[3][i] == a[4][i] && a[2][i] != 0)
                    {
                        point += a[2][i] * 3;
                        for (int j = 2; j < 5; j++)
                        {
                            b[j][i] = 1;
                        }
                    }
                }
                for (int i = 0; i < n; i++)
                {
                    for (int j = 0; j < 5; j++)
                    {
                        if (b[j][i] == 1)
                        {
                            a[j][i] = 0;
                            b[j][i] = 0;
                        }
                    }
                }
                for (int e = 0; e < n; e++)
                {
                    for (int i = 0; i < n; i++)
                    {
                        for (int j = 0; j < 5; j++)
                        {
                            if (a[j][i] == 0)
                            {
                                for (int l = i; l < 10; l++)
                                {
                                    a[j][l] = a[j][l + 1];
                                }
                            }
                        }
                    }
                }
                m--;
            }
            printf("%d\n", point);
            scanf("%d", &n);
        }

        c = getc(stdin);
        if (c == '\n' || c == EOF)
        {
            b_na = true;
            break;
        }
        int t = c - '1';
        oline[ix++] = letter[s][t];
        c = getc(stdin);
    }
    if (b_na)
        printf("NA\n");
    else
    {
        oline[ix] = NUL;
        printf("%s\n", oline);
    }
    if (c == EOF)
        return false;
    return true;
}
int main(int argc, char **argv)
{
    while (true)
    {
        if (!ope_line())
            break;
    }
    return 0;
}