/*
 * =====================================================================================
 *
 *       Filename:  zIBCode.h
 *
 *    Description:  
 *
 *        Version:  1.0
 *        Created:  2012��06��25�� 14ʱ06��35��
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  yjmin
 *        Company:  
 *
 * =====================================================================================
 */
#ifndef Z_IB_CODE_H_YJM
#define Z_IB_CODE_H_YJM

#ifdef __cplusplus
extern "C" {
#endif
/* 
 * ���ѹ���ɹ��򷵻�0����������ֵ��ʾʧ�ܣ�
 * �������-1����ʾ�����������
 * �������-2����ʾ�����ĳ��ȳ���6���ֽ�
 * �������-3����ʾ������ַ�������Ϊ0���߳���11�ֽڣ�
 * �������-4����ʾ������ַ����к��������ַ�������ĸ���ֵ����ͣ�
 * */
int  encodeInterbankBondCode( const unsigned char *pCode, unsigned char pOut[6] );


/* 
 * �������0��ʾ�ɹ�������ʧ�ܣ�
 * �������-1����ʾ����������
 * �������-2����ʾ�����pCode���Ȳ�����
 * */
int decodeInterbankBondCode( const unsigned char pIn[6], unsigned char *pCode, int iCodeBuffLen );


#ifdef __cplusplus
}
#endif
#endif
