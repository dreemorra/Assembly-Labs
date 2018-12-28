#include <windows.h>
#include <dos.h>
#include <stdlib.h>
#include "main.h"

LRESULT CALLBACK WndProc(HWND, UINT, WPARAM, LPARAM);
TCHAR mainMessage[] = "My text"; // ������ � ����������
WORD xPos, yPos, GxPos, GyPos;
int nTimerID;
LPCSTR image = "picture.bmp";
int flg = 0, ClickFlg = 0, op1 = 1, op2 = 0, op3 = 0, op4 = 0;
int t = 0;
// ����������� �������:
int WINAPI WinMain(HINSTANCE hInst, // ���������� ���������� ����������
                   HINSTANCE hPrevInst, // �� ����������
                   LPSTR lpCmdLine, // �� ����������
                   int nCmdShow) // ����� ����������� ������
{
    TCHAR szClassName[] = "My class"; // ������ � ������ ������
    HWND hMainWnd; // ������ ���������� �������� ������
    MSG msg; // ����� ��������� ��������� MSG ��� ��������� ���������
    static HWND hButton, hButton2, hButton3;
    WNDCLASSEX wc; // ������ ���������, ��� ��������� � ������ ������ WNDCLASSEX
    wc.cbSize        = sizeof(wc); // ������ ��������� (� ������)
    wc.style         = CS_HREDRAW | CS_VREDRAW ; // ����� ������ ������
    wc.lpfnWndProc   = WndProc; // ��������� �� ���������������� �������
    wc.lpszMenuName  = NULL; // ��������� �� ��� ���� (� ��� ��� ���)
    wc.lpszClassName = szClassName; // ��������� �� ��� ������
    wc.cbWndExtra    = NULL; // ����� ������������� ������ � ����� ���������
    wc.cbClsExtra    = NULL; // ����� ������������� ������ ��� �������� ���������� ����������
    wc.hIcon         = LoadIcon(NULL, IDI_WINLOGO); // ��������� �����������
    wc.hIconSm       = LoadIcon(NULL, IDI_WINLOGO); // ���������� ��������� ����������� (� ����)
    wc.hCursor       = LoadCursor(NULL, IDC_ARROW); // ���������� �������
    wc.hbrBackground = (HBRUSH)GetStockObject(WHITE_BRUSH); // ���������� ����� ��� �������� ���� ����
    wc.hInstance     = hInst; // ��������� �� ������, ���������� ��� ����, ������������ ��� ������
   	wc.lpszMenuName  = "MAINMENU";
   	SetWindowLong(hMainWnd, GWL_STYLE, GetWindowLong(hMainWnd, GWL_STYLE) and not WS_THICKFRAME);
    if(!RegisterClassEx(&wc)){
        // � ������ ���������� ����������� ������:
        MessageBox(NULL, "Failed to register class", "Error", MB_OK);
        return NULL; // ����������, �������������, ������� �� WinMain
    }
    // �������, ��������� ������:
    hMainWnd = CreateWindow(
        szClassName, // ��� ������
        "Lab �7", // ��� ������ (�� ��� ������)
        WS_OVERLAPPED, // ������ ����������� ������
        CW_USEDEFAULT, // ������� ������ �� ��� �
        NULL, // ������� ������ �� ��� � (��� ������ � �, �� ������ �� �����)
        CW_USEDEFAULT, // ������ ������
        NULL, // ������ ������ (��� ������ � ������, �� ������ �� �����)
        (HWND)NULL, // ���������� ������������� ����
        NULL, // ���������� ����
        hInst, // ���������� ���������� ����������
        NULL); // ������ �� ������� �� WndProc
    hButton = CreateWindow ((LPCSTR)"button", (LPCSTR)"Quit", WS_CHILD | WS_VISIBLE | BS_PUSHBUTTON,  250, 400, 100, 60, hMainWnd, (HMENU)101, hInst, 0);
    hButton2 = CreateWindow ((LPCSTR)"button", (LPCSTR)"Move", WS_CHILD | WS_VISIBLE | BS_PUSHBUTTON,  450, 400, 100, 60, hMainWnd, (HMENU)111, hInst, 0);
    hButton3 = CreateWindow ((LPCSTR)"button", (LPCSTR)"Clear", WS_CHILD | WS_VISIBLE | BS_PUSHBUTTON,  650, 400, 100, 60, hMainWnd, (HMENU)1000, hInst, 0);
	if(!hMainWnd || !hButton || !hButton2){
        // � ������ ������������� �������� ������ (�������� ��������� � ��):
        MessageBox(NULL, "Failed to create a window", "Error", MB_OK);
        return NULL;
    }
    ShowWindow(hMainWnd, nCmdShow); // ���������� ������
    UpdateWindow(hMainWnd); // ��������� ������
    while(GetMessage(&msg, NULL, NULL, NULL)){ // ��������� ��������� �� �������, ���������� ��-�����, ��
        TranslateMessage(&msg); // �������������� ���������
        DispatchMessage(&msg); // ������� ��������� ������� ��
    }
    return msg.wParam; // ���������� ��� ������ �� ����������
}

LRESULT CALLBACK WndProc(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam){
    HDC hDC, hCompatibleDC;
    PAINTSTRUCT PaintStruct;
    HANDLE hBitmap, hOldBitmap;
    PAINTSTRUCT ps;
    RECT Rect;
    int f = 0;
    COLORREF colorText = RGB(255, 0, 0);
    BITMAP Bitmap;
    static int nHDif = 0, nVDif = 0, nHPos = 0, nVPos = 0;
    switch(uMsg){
    case WM_CREATE:
			CreateWindow("EDIT", "",WS_CHILD|WS_VISIBLE|WS_HSCROLL|WS_VSCROLL|ES_MULTILINE|ES_WANTRETURN,CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,hWnd, (HMENU)IDC_MAIN_TEXT, GetModuleHandle(NULL), NULL);
			SendDlgItemMessage(hWnd, IDC_MAIN_TEXT, WM_SETFONT,(WPARAM)GetStockObject(DEFAULT_GUI_FONT), MAKELPARAM(TRUE,0));
			break;
	case WM_LBUTTONDOWN:
 	  if(ClickFlg == 1) break;
      xPos   = LOWORD(lParam);
      yPos   = HIWORD(lParam);
      if(xPos > 840 || xPos < 150) break;
      if(yPos > 250 || yPos < 140) break;
      ClickFlg = 1;
      GxPos = xPos;
      GyPos = yPos;

     		hDC = GetDC(hWnd);
            hBitmap = LoadImage(NULL, image, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE);
            if ( !hBitmap ){
                MessageBox(NULL, "File not found", "Error", MB_OK);
                return 0;
            }
            GetObject(hBitmap, sizeof(BITMAP), &Bitmap);
            hCompatibleDC = CreateCompatibleDC(hDC);

            hOldBitmap = SelectObject(hCompatibleDC, hBitmap);
            GetClientRect(hWnd, &Rect);

            BitBlt(hDC, xPos - 100, yPos - 100, Rect.right - 100, Rect.bottom - 100, hCompatibleDC,nHPos, nVPos, SRCCOPY);
            MoveToEx(hDC, 20, 20 , NULL); 
			LineTo(hDC,1000, 20); 
			LineTo(hDC,1000, 350); 
			LineTo(hDC,20, 350); 
			LineTo(hDC,20, 20);
            DeleteObject(hBitmap);

            DeleteDC(hCompatibleDC);

            EndPaint(hWnd, &PaintStruct);

      ReleaseDC(hWnd, hDC);

        break;

    case WM_TIMER:
		if(flg == 1)
		{
    				hDC = GetDC(hWnd);
		            hBitmap = LoadImage(NULL, image, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE);
		            if ( !hBitmap ){
		                MessageBox(NULL, "File not found", "Error", MB_OK);
		                return 0;
		            }
		            GetObject(hBitmap, sizeof(BITMAP), &Bitmap);
		            hCompatibleDC = CreateCompatibleDC(hDC);

		            hOldBitmap = SelectObject(hCompatibleDC, hBitmap);
		            GetClientRect(hWnd, &Rect);
		            BitBlt(hDC, xPos - 100, yPos - 100, Rect.right - 100, Rect.bottom - 100 + t, hCompatibleDC,nHPos, nVPos, SRCCOPY);
		                MoveToEx(hDC, 20, 20 , NULL); 
					LineTo(hDC,1000, 20); 
					LineTo(hDC,1000, 350); 
					LineTo(hDC,20, 350); 
					LineTo(hDC,20, 20);
		          		if(yPos <= 262 && op1 == 1 && xPos <= 905)
		          		{
		          			 xPos += 2;
		          			 yPos += 2;
		          			 if(yPos >= 262)
                             {

                                 op1 = 0;
                                 op2 = 1;
                             }
                             else
                             if(xPos >= 905)
                             {
                                 op1 = 0;
                                 op3 = 1;
                             }
		          		}
		          			else if(op2 == 1 && yPos >= 112 && xPos <= 905)
                            {
                                xPos += 2;
                                yPos -= 2;
                                if(yPos <= 112)
                                 {

                                     op2 = 0;
                                     op1 = 1;
                                 }
                                 else
                                 if(xPos >= 905)
                                 {
                                     op2 = 0;
                                     op4 = 1;
                                 }
                            }
		          				else if(op3 == 1 && yPos <= 262 && xPos >= 115)
                                {
                                     xPos -= 2;
                                     yPos += 2;
                                     if(yPos >= 262)
                                     {

                                         op3 = 0;
                                         op4 = 1;
                                     }
                                     else
                                     if(xPos <= 115)
                                     {
                                         op3 = 0;
                                         op1 = 1;
                                     }
                                }
		          					else if(op4 == 1 && yPos >=  112 && xPos >= 115)
		          					{
		          						 yPos -= 2;
		          						 xPos -= 2;
		          						 if(yPos <= 112)
                                         {

                                             op4 = 0;
                                             op3 = 1;
                                         }
                                         else
                                         if(xPos <= 115)
                                         {
                                             op4 = 0;
                                             op2 = 1;
                                         }
		          					}
		          		DeleteObject(hBitmap);

		            DeleteDC(hCompatibleDC);

		            EndPaint(hWnd, &PaintStruct);

		     		 ReleaseDC(hWnd, hDC);
		}
    	break;
    case WM_COMMAND:
			switch(LOWORD(wParam))
			{
				case CLOSE:

				     switch ((int)MessageBox(NULL, "Are you sure you want to quit?", "Warning",
                             MB_ICONQUESTION | MB_YESNO))
				     {
					     case IDYES: DestroyWindow(hWnd);break;
					     case IDNO:  break;
				     }
					break;

				case SWITCH:
					if(flg == 0)
					{
						if(ClickFlg == 0)
						{
							MessageBox(NULL, "The image is not drawn","Error", MB_OK);
							break;
						}
						image = "picture.bmp";
						nTimerID = SetTimer(hWnd, 1, 1, NULL);
						flg = 1;
					}
					else
					{
						KillTimer(hWnd, 1);
						image = "picture.bmp";
						hDC = GetDC(hWnd);
			            hBitmap = LoadImage(NULL, image, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE);
			            if ( !hBitmap ){
			                MessageBox(NULL, "File not found", "Error", MB_OK);
			                return 0;
			            }
			            GetObject(hBitmap, sizeof(BITMAP), &Bitmap);
			            hCompatibleDC = CreateCompatibleDC(hDC);

			            hOldBitmap = SelectObject(hCompatibleDC, hBitmap);
			            GetClientRect(hWnd, &Rect);
			            BitBlt(hDC, xPos - 100, yPos - 100, Rect.right - 100, Rect.bottom - 100 + t, hCompatibleDC,nHPos, nVPos, SRCCOPY);
                           MoveToEx(hDC, 20, 20 , NULL); 
						LineTo(hDC,1000, 20); 
						LineTo(hDC,1000, 350); 
						LineTo(hDC,20, 350); 
						LineTo(hDC,20, 20);
          				DeleteObject(hBitmap);
          			    DeleteDC(hCompatibleDC);
        			    EndPaint(hWnd, &PaintStruct);
    					ReleaseDC(hWnd, hDC);
						flg = 0;
					}
					break;

				case CLEAR:
					ClickFlg = 0;
					KillTimer(hWnd, 1);
					image = "picture.bmp";
					flg = 0;
					InvalidateRect(hWnd, 0, TRUE);
					UpdateWindow(hWnd);
					MessageBox(NULL, "Cleared","Message", MB_OK);
					break;
			}
			break;
    case WM_CLOSE:
    	PostQuitMessage(NULL);
		DestroyWindow(hWnd);
		break;
    case WM_DESTROY: // ���� ������ ���������, ��:
        PostQuitMessage(NULL); // ���������� WinMain() ��������� WM_QUIT
        break;
    default:
        return DefWindowProc(hWnd, uMsg, wParam, lParam); // ���� ������� ������
    }
    return NULL; // ���������� ��������
}
