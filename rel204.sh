#!/bin/bash

##  REL204.SH
##  -------------------
##  GERA RELATORIOS PARA FILIAL

## @thibac10 - Thiago B. (Criado em 08.06.2023)

## ///////////////////////////////////////////////////////

version="V1.6.4"

## Arquivos necessários para execução Shell REL204
# • imprimir
# • email204

# Parâmetros de execução:
# -noemail  :: Executa o rel204 sem e'mails.
# -noprint  :: Executa o rel204 sem impressões.
#
# Ex. rel204 -noemail -noprint

version="V1.6.4"

#############  Variáveis Globais  ###########################
#  !! Não alterar as variáveis globais !!

data=$(date "+%d%m%y")   # NAO ALTERAR
send_email=1             # NAO ALTERAR
send_printer=1           # NAO ALTERAR

DIA_HOJE=`date +'%d'`
HORA_HOJE=`date +'%H'`

if [ $HORA_HOJE -lt 10 ];
    then
    
    # Define data corrente para o dia anterior
    date=$(date -d 'yesterday' '+%d/%m/%Y') #dd/mm/aaaa
else
    # Define data corrente para o dia atual
    date=$(date -d 'today' '+%d/%m/%Y') #dd/mm/aaaa
fi

# Parâmetros
param1=$1               # NÃO ALTERAR
param2=$2               # NÃO ALTERAR

## Diretórios
# OBS.: NÃO acrescentar "/" (barra) no final do diretório.
# Ex. /fs1/save/ -- ERRADO
# Ex. /fs1/save  -- CERTO

gerencial=/files/gerencial/administrativo/Gerencial
sis=/files/gerencial/administrativo/sis
isv=/files/gerencial/administrativo/ISV
relatorios_diario=/files/gerencial/relatorios_diario
bk=/fs1/save/bk
administrativo=/files/gerencial/administrativo
dir_imprimir=/files/gerencial/imprimir

## Variáveis de Funcionamento do SHELL
log_rel204=$(echo /files/gerencial/rel204/log/rel204_$data.log)
interface_rel204=/files/gerencial/rel204/rel204_interface
dir_rel204=/files/gerencial/rel204

# Reinicialização Mensal para relatório Impressões
#if [ $DIA_HOJE -eq 02 ];
    #then

    #data_001=$(tail -n 1 $dir_rel204/impressora_gerencia.csv);
    #data_002=$(tail -n 1 $dir_rel204/impressora_nfe.csv);
    #data_003=$(tail -n 1 $dir_rel204/impressora_rm.csv);
    
    # Cria estrutura
    #line_1="Data;Folhas impressas;Paginas impressas;";
    
    #echo $line_1 > $dir_rel204/impressora_gerencia.csv;
    #echo " " >> $dir_rel204/impressora_gerencia.csv;
    
    #echo $line_1 > $dir_rel204/impressora_nfe.csv;
    #echo " " >> $dir_rel204/impressora_nfe.csv;
    
    #echo $line_1 > $dir_rel204/impressora_rm.csv;
    #echo " " >> $dir_rel204/impressora_rm.csv;
    
    # Define valores de inicializacao do mes
    #echo "initiation//;${data_001:11:20}" >> $dir_rel204/impressora_gerencia.csv;
    #echo " " >> $dir_rel204/impressora_gerencia.csv;
    
    #echo "initiation//;${data_002:11:20}" >> $dir_rel204/impressora_nfe.csv;
    #echo " " >> $dir_rel204/impressora_nfe.csv;
    
    #echo "initiation//;${data_003:11:20}" >> $dir_rel204/impressora_rm.csv;
    #echo " " >> $dir_rel204/impressora_rm.csv;

#fi

############## FUNÇÕES  #############################

atualizar_tela() { 
    # SINTAXE : atualizar_tela [mensagem_temporaria] 
  
    # Obs.: O parametro 'mensagem_temporaria' não é obrigatório.
    mensagem_temporaria=$1

    if [ $# -eq 1 ]; then
        clear
        more $interface_rel204
        echo -e "$mensagem_temporaria";
    else
        clear
        more $interface_rel204
    fi
}

exe() { 
    # A funcao 'exe' executa um comando em segundo plano e continua a execucao do script
    # SINTAXE:  exe [comando] [descricao]   --

    # EXEMPLO:
    # exe 'cp arquivo.txt /home' 'Copiando arquivo para o \/home'

    echo "Iniciado Execucao: '$1' --> [ $(date "+%d/%m/%y %H:%M:%S") ]" >> $log_rel204

    if [ $# -eq 2 ]; then
        nohup $1 >> $log_rel204 &
        echo "$2" >> $interface_rel204
        atualizar_tela
    else
        nohup $1 >> $log_rel204 &
        atualizar_tela
    fi
}

rel_impressora() { 
    # +--------------------------------------+
    # |   Coleta relatorios das impressoras  |
    # +--------------------------------------+
    
    atualizar_tela '   - Verificando numero de impressoes...'

    ##### Gerencia  #####
    
    exe 'wget http://10.120.232.21/cgi-bin/dynamic/printer/config/reports/devicestatistics.html'
    #nohup wget http://10.120.232.21/cgi-bin/dynamic/printer/config/reports/devicestatistics.html >> $log_rel204 &
    #wget http://10.120.232.21/cgi-bin/dynamic/printer/config/reports/devicestatistics.html >> $log_rel204
    atualizar_tela '   - Verificando numero de impressoes...'
    wait
    sleep 2
    folhas=$(cat devicestatistics.html | grep -n ^ | grep ^72)
    paginas=$(cat devicestatistics.html | grep -n ^ | grep ^97)
    echo "$date;${folhas:73:9};${paginas:73:9};" >> $dir_rel204/impressora_gerencia.csv
    echo "$date;${folhas:73:9};${paginas:73:9};" >> $dir_rel204/impressora_gerencia_historico.csv
    rm devicestatistics.html
    folhas=""; paginas="";
    
   
    ##### RM  #####
    
    exe 'wget http://10.120.232.22/cgi-bin/dynamic/printer/config/reports/devicestatistics.html'
    #nohup wget http://10.120.232.22/cgi-bin/dynamic/printer/config/reports/devicestatistics.html >> $log_rel204 &
    #wget http://10.120.232.22/cgi-bin/dynamic/printer/config/reports/devicestatistics.html >> $log_rel204
    atualizar_tela '   - Verificando numero de impressoes...'
    wait
    sleep 2
    folhas=$(cat devicestatistics.html | grep -n ^ | grep ^70)
    paginas=$(cat devicestatistics.html | grep -n ^ | grep ^111)
    echo "$date;${folhas:73:9};${paginas:74:9};" >> $dir_rel204/impressora_rm.csv
    echo "$date;${folhas:73:9};${paginas:74:9};" >> $dir_rel204/impressora_rm_historico.csv
    rm devicestatistics.html
    folhas=""; paginas="";
    
    
    ##### Caixa empresa  #####
    
    exe 'wget http://10.120.232.24/cgi-bin/dynamic/printer/config/reports/devicestatistics.html'
    #nohup wget http://10.120.232.24/cgi-bin/dynamic/printer/config/reports/devicestatistics.html >> $log_rel204 &
    #wget http://10.120.232.24/cgi-bin/dynamic/printer/config/reports/devicestatistics.html >> $log_rel204
    atualizar_tela '   - Verificando numero de impressoes...'
    wait
    sleep 2
    folhas=$(cat devicestatistics.html | grep -n ^ | grep ^72)
    paginas=$(cat devicestatistics.html | grep -n ^ | grep ^107)
    echo "$date;${folhas:73:9};${paginas:74:9};" >> $dir_rel204/impressora_nfe.csv
    echo "$date;${folhas:73:9};${paginas:74:9};" >> $dir_rel204/impressora_nfe_historico.csv
    rm devicestatistics.html
    
    
    echo "   - Verificado numero de impressoes: Gerencia, RM e Caixa Empresa." >> $interface_rel204
    echo " " >> $interface_rel204
}

gerar_rel(){
    # +--------------------------------------------------+
    # |    RESPONSAVEL PELA GERACAO DE RELATORIOS        |
    # +--------------------------------------------------+


    cd /fs1/save/
    #echo -e "\n   Gerando $descricao [...]";
    
    # Organização do Log - Para melhor visualização/conferência das informações
    echo -e "=================================================================================================" >> $log_rel204;
    echo -e "\n[ $descricao ]" >> $log_rel204;
    
    # Execução
    exe "$parametro"
    atualizar_tela "\n   Gerando $descricao [...]"
    wait
    
    # Destino_1
    if [ $destino_1 != "null" ]; then
        cp $bk/$nome_arq_bk $destino_1
    fi
    # Destino_2
    if [ $destino_2 != "null" ]; then
        cp $bk/$nome_arq_bk $destino_2
    fi
    # Impressão
    if [ $impressao = "yes" ]; then
        cp $bk/$nome_arq_bk $dir_imprimir
    fi
    echo "   - $descricao Gerado." >> $interface_rel204
    atualizar_tela
}


limpeza_antes_rel204(){ 

    # EXCLUINDO RELATÓRIOS DO BK
    cd /fs1/save/bk
    rm -f srt50.* # RELATORIO DE VENDAS POR COMPRADOR
    rm -f srt51.* # MERCADORIAS C/ ESTOQUE ZERO
    rm -f sae60.* # VENCIMENTO DE MERCADORIAS POR PERIODO
    rm -f sae51.* # RELATORIO DE MERCADORIAS POR EVENTO
    rm -f srt53.*
    rm -f srm02.* # ESPELHO DE PEDIDOS PENDENTES
    rm -f srt03.* # ANALISE  DE VENDAS DE MERCADORIAS (CAFETERIA)
    
    # EXCLUINDO ARQUIVOS: GERENCIAL, RELATORIOS_DIARIO, IMPRIMIR
    rm -f /files/gerencial/administrativo/Gerencial/*
    rm -f /files/gerencial/administrativo/sis/*
    rm -f /files/gerencial/relatorios_diario/*
    rm -f /files/gerencial/imprimir/*
}

check_exe_email_impressao() { 
    
    # +-------------------------------------------------------------------+
    # |   CAPTURA OS PARAMETROS PASSADOS PELO SHELL ANTES DA EXECUCAO     |
    # +-------------------------------------------------------------------+
 

    # PARAMETRO : CASO 1
    if [ $param1 == "-noemail" ];
    then
        send_email=0;
        echo "   * Executando sem email's";
        if [ $param2 == "-noprint" ];
        then
            send_printer=0;
            echo "   * Executando sem impressoes";
        fi
        echo "";
    fi
    
    # PARAMETRO : CASO 2
    if [ $param1 == "-noprint" ];
    then
        send_printer=0;
        echo "   * Executando sem impressoes";
        
        if [ $param2 == "-noemail" ];
        then
            send_email=0;
            echo "   * Executando sem email's";
        fi
        echo "";
    fi
}

msg_box(){
    string=$1

    if [ $# -eq 2 ]; then
        time=$2
    else
        time=1
    fi

    p_inicial_col=14 # Coluna inicial para escrita do texto 
    NCarac=${#string}
    NCarac_left=$(((${#string}-50)/2*-1+$p_inicial_col))
  
    clear
    echo "==============================================================================="      > $interface_rel204
    echo "|                                                                             |"      >> $interface_rel204
    echo "|               REL204 - Desenvolvido por CPD Mogi das Cruzes                 |"      >> $interface_rel204
    echo "|----------------------------------------------------------------- [$version] --|"    >> $interface_rel204
    for line in {1..6}; do 
        echo "|                                                                             |"  >> $interface_rel204;
    done
    echo "|          +------------------------------------------------------+           |"      >> $interface_rel204
    echo "|          |                                                      |           |"      >> $interface_rel204
    echo "|          |                                                      |           |"      >> $interface_rel204
    echo "|          |                                                      |           |"      >> $interface_rel204
    echo "|          +------------------------------------------------------+           |"      >> $interface_rel204
    for line in {1..7}; do 
        echo "|                                                                             |"  >> $interface_rel204;
    done
    echo "==============================================================================="      >> $interface_rel204
  
    atualizar_tela
    tput cup 12 $NCarac_left
    echo $string
    tput cup 23 0
    sleep $time
}

exe_shell(){
    # DECLARACAO DE USO DA FUNCAO 
  
    # -- Sintaxe para chamada de um Shell em segundo plano: --
    #  Para execução de um shell em segundo plano usa-se a funcao "exe_shell" seguido do nome do shell e sua descricao, conforme abaixo:
    #
    # exe_shell 'shell.sh' 'texto_a_ser_apresentado'
    #
    # OBS: O texto a ser apresentado na chamada acima nao deve exceder 50 caracteres, os demais caracteres serao truncados. 

    texto_a_ser_apresentado=$2
    p_inicial_col=14 # Coluna inicial para escrita do texto 
    NCarac=${#texto_a_ser_apresentado}
    NCarac_left=$(((${#texto_a_ser_apresentado}-50)/2*-1+$p_inicial_col))
  
    echo -e "\n :::: Saida da chamada : \"$1\" ::::\n" >> $log_rel204
    clear
    echo "==============================================================================="      > $interface_rel204
    echo "|                                                                             |"      >> $interface_rel204
    echo "|               REL204 - Desenvolvido por CPD Mogi das Cruzes                 |"      >> $interface_rel204
    echo "|----------------------------------------------------------------- [$version] --|"    >> $interface_rel204
    for line in {1..6}; do 
        echo "|                                                                             |"  >> $interface_rel204;
    done
    echo "|          +------------------------------------------------------+           |"      >> $interface_rel204
    echo "|          |                                                      |           |"      >> $interface_rel204
    echo "|          |                                                      |           |"      >> $interface_rel204
    echo "|          |                                                      |           |"      >> $interface_rel204
    echo "|          +------------------------------------------------------+           |"      >> $interface_rel204
    for line in {1..7}; do 
        echo "|                                                                             |"  >> $interface_rel204;
    done
    echo "==============================================================================="      >> $interface_rel204
    echo "Iniciado Shell: '$1' --> [ $(date "+%d/%m/%y %H:%M:%S") ]" >> $log_rel204
    
    nohup $1 >> $log_rel204 &
    atualizar_tela
    tput cup 12 $NCarac_left
    echo $texto_a_ser_apresentado
    tput cup 23 0
    sleep 2;
    wait
}

###########################   SEQUENCIA SHELL   #################################
    # +-------------------------------------------------------------------+
    # |                 ::::        MAIN          ::::                    |
    # +-------------------------------------------------------------------+
 

cd /fs1/save/
clear
echo "==============================================================================="   > $interface_rel204
echo "|                                                                             |"   >> $interface_rel204
echo "|               REL204 - Desenvolvido por CPD Mogi das Cruzes                 |"   >> $interface_rel204
echo "|----------------------------------------------------------------- [$version] --|" >> $interface_rel204
echo "|          Relatorios sendo gerados para atualizacao do Gerencial             |"   >> $interface_rel204
echo "==============================================================================="   >> $interface_rel204
echo ""                                                                                  >> $interface_rel204
check_exe_email_impressao                                                                >> $interface_rel204
echo "   - Excluido: - Relatorios do BK."                                                >> $interface_rel204
echo "               - Arquivos do diretorio Gerencial."                                 >> $interface_rel204
echo " "                                                                                 >> $interface_rel204
#rel_impressora
atualizar_tela
limpeza_antes_rel204 # Limpeza antes de gerar os relatórios.


############################  GERACAO DE RELATORIOS  ###################################
    # +-------------------------------------------------------------------+
    # |                     ::::   DATA ATUAL     ::::                    |
    # +-------------------------------------------------------------------+
 

## *** Todas as variáveis devem estar preenchidas para cada relatório. *** ##
## Exemplo de relatório:
## descricao="SAEBI51 - [Ajuste]"; parametro="dfrun exe saebi51 1 204 0 010151 010151 0 1 0 0"; nome_arq_bk="sae51*.csv"; destino_1=$Gerencial; destino_2="null"; impressao="yes";
## No exemplo acima será gerado o relatório SAEBI51 e seu arquivo gerado "sae51*.csv" será copiado para o Gerencial, tendo uma cópia tambem na pasta imprimir. 
## Após preechimentos das variáveis executa-se a função "gerar_rel".


# :::: SAEBI51 - RELATORIO 1 :::: 
descricao="SAEBI51 - [Relatorio 1]";
parametro="dfrun exe saebi51 1 204 0 010151 010151 0 1 0 0";
nome_arq_bk="sae51*.csv";
destino_1=$gerencial;
destino_2="null";
impressao="no";
gerar_rel
rm /fs1/save/bk/sae51*


# :::: SAEBI51 - RELATORIO 2 :::: 
descricao="SAEBI51 - [Relatorio 2]";
parametro="dfrun exe saebi51 1 204 0 010151 010151 0 2 0 0";
nome_arq_bk="sae51*.csv";
destino_1=$gerencial;
destino_2="null";
impressao="no";
gerar_rel
rm /fs1/save/bk/sae51*


# :::: SAEBI51 - RELATORIO 3 :::: 
descricao="SAEBI51 - [Relatorio 3]";
parametro="dfrun exe saebi51 1 204 0 010151 010151 0 3 0 0";
nome_arq_bk="sae51*.csv";
destino_1=$gerencial;
destino_2="null";
impressao="no";
gerar_rel
rm /fs1/save/bk/sae51*


# :::: SAEBI51 - RELATORIO 4 :::: 
descricao="SAEBI51 - [Relatorio 4]";
parametro="dfrun exe saebi51 1 204 0 010151 010151 0 4 0 0";
nome_arq_bk="sae51*.csv";
destino_1=$gerencial;
destino_2="null";
impressao="no";
gerar_rel
rm /fs1/save/bk/sae51*

# Concatenando relatórios - SAEBI51
cd $gerencial
cat sae51*.csv > sae51.f204.csv

# :::: SAEBI60 :::: 
descricao="SAEBI60";
parametro="dfrun exe saebi60 1 204 0 010151 010151 9999 0 0 1";
nome_arq_bk="sae60*.csv";
destino_1=$gerencial/sae60.f204.csv;
destino_2="null";
impressao="no";
gerar_rel


# :::: SRTBI51 :::: 
descricao="SRTBI51";
parametro="dfrun exe srtbi51 1 204 0 010121 010121 1 3 0 0";
nome_arq_bk="srt51*";
destino_1=$relatorios_diario;
destino_2="null";
impressao="no";
gerar_rel


# :::: SRMBI02 :::: 
descricao="SRMBI02";
parametro="dfrun exe srmbi02 1 204 0 010121 010121 0 0 999 801";
nome_arq_bk="srm02*.csv";
destino_1=$gerencial/srm02.f204.csv;
destino_2="null";
impressao="no";
gerar_rel


# :::: SRTBI36 :::: 
descricao="SRTBI36";
parametro="dfrun exe srtbi36 1 204 0 010121 010121 1 9999 2 2";
nome_arq_bk="srt36*.csv";
destino_1=$gerencial/srt36.f204.csv;
destino_2="null";
impressao="no";
gerar_rel


# :::: SVDBI08 :::: 
descricao="SVDBI08";
parametro="dfrun exe svdbi08 1 204 0 010121 010121 2 0 1 9999";
nome_arq_bk="svd08_mensal*";
destino_1=$relatorios_diario;
destino_2="null";
impressao="no";
gerar_rel


# :::: SMGBI23 :::: 
#descricao="SMGBI23";
#parametro="dfrun exe smgbi23 1 204 0 010121 010121 0 0 1 1";
#nome_arq_bk="smg23*.csv";
#destino_1=$gerencial/smg23.f204.csv;
#destino_2="null";
#impressao="no";
#gerar_rel # Gerado no Batch
cp $bk/smg23*.csv $gerencial/smg23.f204.csv


# :::: SMGBI11 :::: 
#descricao="SMGBI11";
#parametro="dfrun exe smgbi11 1 204 0 010121 010121 1 1 0 0";
#nome_arq_bk="smg11*.csv";
#destino_1=$gerencial/smg11.f204.csv;
#destino_2="null";
#impressao="no";
#gerar_rel # Gerado no Batch
cp $bk/smg11*.csv $gerencial/smg11.f204.csv


# :::: SVDBI04 :::: 
#descricao="SVDBI04";
#parametro="dfrun exe svdbi04 1 204";
#nome_arq_bk="svd04*";
#destino_1="null";
#destino_2="null";
#impressao="no";
#gerar_rel



descricao="SRTBI03 - [Geral]"; parametro="dfrun exe srtbi03 1 204 0 010121 010121 0 0 0 1"; nome_arq_bk="srt03*.csv"; destino_1=$gerencial/srt03.f204.geral.csv; destino_2=$sis/srt03.f204.geral.csv; impressao="no";
gerar_rel
rm /fs1/save/bk/srt03*

# Gerado no Batch
cp $bk/smg12.*csv $isv/smg12.csv

    # +-------------------------------------------------------------------+
    # |                 ::::   DATA ANTERIOR    ::::                      |
    # +-------------------------------------------------------------------+

## *** Todas as variáveis devem estar preenchidas para cada relatório. *** ##
## Exemplo de relatório:
## descricao="SAEBI51 - [Ajuste]"; parametro="dfrun exe saebi51 1 204 0 010151 010151 0 1 0 0"; nome_arq_bk="sae51*.csv"; destino_1=$Gerencial; destino_2="null"; impressao="yes";
## No exemplo acima será gerado o relatório SAEBI51 e seu arquivo gerado "sae51*.csv" será copiado para o Gerencial, tendo uma cópia tambem na pasta imprimir. 
## Após preechimentos das variáveis executa-se a função "gerar_rel".
clear
echo "==============================================================================="   > $interface_rel204
echo "|                                                                             |"   >> $interface_rel204
echo "|               REL204 - Desenvolvido por CPD Mogi das Cruzes                 |"   >> $interface_rel204
echo "|----------------------------------------------------------------- [$version] --|" >> $interface_rel204
echo "|          Relatorios sendo gerados para atualizacao do Gerencial             |"   >> $interface_rel204
echo "==============================================================================="   >> $interface_rel204
echo " "                                                                                 >> $interface_rel204
echo "   [ Alteracao da data batch para o dia anterior ]"                                >> $interface_rel204
echo " "                                                                                 >> $interface_rel204 
atualizar_tela
sleep 3

dfrun exe sadou09
atualizar_tela


# :::: SRTBI03 - Diario - Loja :::: 
descricao="SRTBI03 - [Relatorio 1]";
parametro="dfrun exe srtbi03 1 204 0 010121 010121 0 0 0 0";
nome_arq_bk="srt03*";
destino_1=$relatorios_diario;
destino_2="null";
impressao="no";
gerar_rel
rm /fs1/save/bk/srt03*


# :::: SRTBI03 :::: 
descricao="SRTBI03 - [Relatorio 2]";
parametro="dfrun exe srtbi03 1 204 0 010121 010121 0 0 1 0";
nome_arq_bk="srt03.*";
destino_1="null";
destino_2="null";
impressao="no";
gerar_rel


# :::: SRTBI03 :::: 
descricao="SRTBI03 - [Cafeteria - Diario]";
parametro="dfrun exe srtbi03 1 204 0 010121 010121 1 0 1 0";
nome_arq_bk="srt03*";
destino_1="null";
destino_2="null";
impressao="no";
gerar_rel


# :::: SAEBI51 :::: 
descricao="SAEBI51 - [Avaria]";
parametro="dfrun exe saebi51 1 204 0 010151 010151 7 1 0 3";
nome_arq_bk="sae51.f204.avaria*.csv";
destino_1=$sis/sae51.f204.avaria.csv;
destino_2="null";
impressao="no";
gerar_rel


# :::: SAEBI51 :::: 
descricao="SAEBI51 - [Ajuste]";
parametro="dfrun exe saebi51 1 204 0 010151 010151 7 2 0 3";
nome_arq_bk="sae51.f204.ajuste*.csv";
destino_1=$sis/sae51.f204.ajuste.csv;
destino_2="null";
impressao="no";
gerar_rel


# :::: SRTBI50 :::: 
descricao="SRTBI50 - [Relatorio 1]";
parametro="dfrun exe srtbi50 1 204 0 010121 010121 0 0 0 0 2";
nome_arq_bk="srt50*.csv";
destino_1=$gerencial/srt50.f204.csv;
destino_2="null";
impressao="no";
gerar_rel
rm /fs1/save/bk/srt50*


# :::: SRTBI50 :::: 
descricao="SRTBI50 - [Relatorio 2]";
parametro="dfrun exe srtbi50 1 204 0 010121 010121 0 0 0 0";
nome_arq_bk="srt50*";
destino_1="null";
destino_2="null";
impressao="no";
gerar_rel


# :::: SAEBI17 :::: 
descricao="SAEBI17";
parametro="dfrun exe saebi17 1 204 0 010108 010108 0 999 0 0";
nome_arq_bk="sae17*";
destino_1="null";
destino_2="null";
impressao="no";
gerar_rel


# :::: SCDBI61 :::: 
descricao="SCDBI61 - [NC]";
parametro="dfrun exe scdbi61 1 204 0 010121 010121 1 1 1 1";
nome_arq_bk="scd61*";
destino_1="null";
destino_2="null";
impressao="no";
gerar_rel


# :::: SVDBI02 :::: 
#descricao="SVDBI02";
#parametro="dfrun exe svdbi02 1 204";
#nome_arq_bk="svd02*";
#destino_1="null";
#destino_2="null";
#impressao="no";
#gerar_rel

#############################  FINAL RELATORIOS DIA ANTERIOR   #############################


echo -e "\n   [ Alteracao da data batch para o dia atual ]"                              >> $interface_rel204
echo " "                                                                                 >> $interface_rel204
atualizar_tela
sleep 3
dfrun exe sadou09

msg_box 'Relatorios Gerados.' 3
clear
echo "==============================================================================="   > $interface_rel204
echo "|                                                                             |"   >> $interface_rel204
echo "|               REL204 - Desenvolvido por CPD Mogi das Cruzes                 |"   >> $interface_rel204
echo "|----------------------------------------------------------------- [$version] --|" >> $interface_rel204
echo "|                                                                             |"   >> $interface_rel204
echo "|                                                                             |"   >> $interface_rel204
echo "|                                                                             |"   >> $interface_rel204
echo "|                                                                             |"   >> $interface_rel204
echo "|                                                                             |"   >> $interface_rel204
echo "|                                                                             |"   >> $interface_rel204
echo "|          +------------------------------------------------------+           |"   >> $interface_rel204
echo "|          |                                                      |           |"   >> $interface_rel204
echo "|          |          Copiando arquivos para a pasta:             |           |"   >> $interface_rel204
echo "|          |                                                      |           |"   >> $interface_rel204
echo "|          |                 relatorios_diario                    |           |"   >> $interface_rel204
echo "|          |                                                      |           |"   >> $interface_rel204
echo "|          +------------------------------------------------------+           |"   >> $interface_rel204
echo "|                                                                             |"   >> $interface_rel204
echo "|                                                                             |"   >> $interface_rel204
echo "|                                                                             |"   >> $interface_rel204
echo "|                                                                             |"   >> $interface_rel204
echo "|                                                                             |"   >> $interface_rel204
echo "==============================================================================="   >> $interface_rel204
atualizar_tela


# ---------------------------------------------
#      Copiando do BK para relatorios diario
# ---------------------------------------------
cd $bk
chmod 777 *
cp sae06* $relatorios_diario
cp sae08* $relatorios_diario
cp sae17* $relatorios_diario
cp sae25* $relatorios_diario
cp sas08* $relatorios_diario
cp sas22* $relatorios_diario
cp sas36* $relatorios_diario
cp sas38* $relatorios_diario
cp sas64* $relatorios_diario
cp scd61* $relatorios_diario
cp sit23* $relatorios_diario
cp smg23* $relatorios_diario
cp smg12* $relatorios_diario
cp spa09* $relatorios_diario
cp srm01* $relatorios_diario
cp srm02* $relatorios_diario
cp srm03* $relatorios_diario
cp srm28* $relatorios_diario
cp srm32* $relatorios_diario
cp srt36* $relatorios_diario
cp srt50* $relatorios_diario
cp svd02* $relatorios_diario
cp svd04* $relatorios_diario
cp svd07* $relatorios_diario
cp svd08_diario* $relatorios_diario
cp svd18* $relatorios_diario
cp svd62* $relatorios_diario
cp svd86* $relatorios_diario
cp svda2* $relatorios_diario
cp srm09* $relatorios_diario
cp sas61* $relatorios_diario
cp scd99* $relatorios_diario
cp svd18* $relatorios_diario



# -----------------------------------
# |     Relatorios Diario           |
# -----------------------------------
cd $relatorios_diario
mv sae06*csv Sae06.csv
mv sae06* sae06.txt
mv sae08*csv Sae08.csv
mv sae08* sae08.txt
mv sae17*csv Sae17.csv
mv sae17* sae17.txt
mv sae25*csv Sae25.csv
mv sae25* sae25.txt
#mv sas08*csv Sas08.csv
mv sas08* sas08.txt
mv sas36*csv Sas36.csv
mv sas36* sas36.txt
mv sas38*csv Sas38.csv
mv sas38* sas38.txt
mv sas64*csv Sas64.csv
mv sas64* sas64.txt
mv scd61.fl*csv Scd61_fl.csv
mv scd61.fl* scd61_fl.txt
mv scd61.nc*csv Scd61_nc.csv
mv scd61.nc* scd61_nc.txt
mv sit23*csv Sit23.csv
# mv sit23* sit23.txt
mv smg23*csv Smg23.csv
mv smg12*csv Smg12.csv
mv spa09* spa09.txt
mv smg12* smg12.txt
mv srm01*csv Srm01.csv
mv srm01* srm01.txt
mv srm02*csv Srm02.csv
mv srm02* srm02.txt
mv srm03* srm03.txt
mv srm28*csv Srm28_0.csv
mv srm28* srm28_0.txt
mv srm32* srm32.txt
mv srt36*csv Srt36.csv
mv srt36* srt36.txt
mv srt50*csv Srt50.csv
mv srt50* srt50.txt
mv svd02*csv Svd02.csv
mv svd02* Svd02.txt
mv svd04*csv Svd04.csv
mv svd04* svd04.txt
mv svd07*csv Svd07.csv
mv svd07* svd07.txt
mv svd08_diario*csv Svd08_diario.csv
mv svd08_diario*[0-9] svd08_diario.txt
mv svd08_mensal*csv Svd08_mensal.csv
mv svd08_mensal*[0-9] svd08_mensal.txt
mv svd18*csv svd18.f204.csv
mv svd18* svd18.txt
mv svd62*csv Svd62.csv
mv svd62* svd62.txt
mv svd86*csv Svd86.csv
mv svd86* svd86.txt
mv svda2*csv Svda2.csv
mv svda2* svda2.txt
mv srm09* srm09.txt
mv sas61* sas61.txt
mv scd99* scd99.txt
mv sas22*csv Sas22.csv
mv sas22* sas22.txt
mv srt03.f204.geral*csv srt03.f204.diario.csv
mv srt51*.csv srt51.f204.csv
chmod 777 *.*

cp Sit23.csv $gerencial
cp Sas22.csv $gerencial
cp svd18.f204.csv $gerencial
cp sas22.txt $administrativo
cp Svda2.csv $gerencial
cp srt51.f204.csv $gerencial 

cp srt50.txt $sis/srt50.f204.txt
cp srt36.txt $sis/srt36.f204.txt
cp srt03.f204.diario.csv $sis

# Relatorios Impressoras
cp /files/gerencial/rel204/impressora_gerencia.csv $sis
cp /files/gerencial/rel204/impressora_nfe.csv $sis
cp /files/gerencial/rel204/impressora_rm.csv $sis

# Modificacao para copiar e imprimir o Mapa Resumo aos Domingos e Feriados
DIA_HOJE=`date -d 'today' '+%m%d'`
DIA_ONTEM=`date -d 'yesterday' '+%m%d'`
HORA_HOJE=`date +'%H'`

if [ $HORA_HOJE -gt 14 ] ; then
   cp /fs1/pdv/tplinux/MapaResumo*$DIA_HOJE.pdf $dir_imprimir
   cp /fs1/pdv/tplinux/MapaResumo*$DIA_HOJE.pdf $relatorios_diario
else
   cp /fs1/pdv/tplinux/MapaResumo*$DIA_ONTEM.pdf $dir_imprimir
   cp /fs1/pdv/tplinux/MapaResumo*$DIA_ONTEM.pdf $relatorios_diario
fi

# Fim cópia relatorios diario
msg_box 'Relatorios copiados.' 3

if [ $send_email == 1 ];
  then
  exe_shell 'email204' 'Enviando relatorios por email...'
fi

msg_box 'Copiando relatorios para impressao...' 2
cd $bk

# Contabilidade
cp svd08_diario.f204* $dir_imprimir
cp srt01* $dir_imprimir
cp sas64* $dir_imprimir
cp sas90* $dir_imprimir
cp svd41* $dir_imprimir
cp srm09* $dir_imprimir
cp svd07* $dir_imprimir

# Gerente Comercial
cp srt50* $dir_imprimir 
cp sit23* $dir_imprimir

# RM
cp srm01* $dir_imprimir
cp srt01* $dir_imprimir 
cp srm32* $dir_imprimir

# Cafeteria
cp srt03.f204.cafet_diario* $dir_imprimir
cp svd62* $dir_imprimir

# CPD
cp sas08* $dir_imprimir

# Frente de caixa
cp srt50* $dir_imprimir

# Gerente ADM
#cp sas36* $dir_imprimir
#cp sas85* $dir_imprimir

rm /files/gerencial/imprimir/*.csv
rm /files/gerencial/imprimir/*.bdy
rm /files/gerencial/imprimir/*.pdf

chmod 777 $administrativo/*
chmod 777 $sis/*
chmod 777 $gerencial/*


if [ $send_printer == 1 ];
  then
  exe_shell 'imprimir' 'Imprimindo relatorios...'
fi


## Chamadas de outros Shells

exe_shell 'plan_geral' 'Gerando base p/ Relatorio geral...'
exe_shell 'classe.sh' 'Executando Shell Classe.sh [...]'
exe_shell 'prevencao.sh' 'Executando Shell Prevencao.sh [...]'
exe_shell 'resultados.sh' 'Executando Shell Resultados.sh [...]'
exe_shell 'diferenca.sh' 'Executando Shell Diferenca.sh [...]'

clear
echo "==============================================================================="    > $interface_rel204
echo "|                                                                             |"    >> $interface_rel204
echo "|               REL204 - Desenvolvido por CPD Mogi das Cruzes                 |"    >> $interface_rel204
echo "|----------------------------------------------------------------- [$version] --|"  >> $interface_rel204
echo "|                                                                             |"    >> $interface_rel204
echo "|                                                                             |"    >> $interface_rel204
echo "|                                                                             |"    >> $interface_rel204
echo "|                                                                             |"    >> $interface_rel204
echo "|                                                                             |"    >> $interface_rel204
echo "|                                                                             |"    >> $interface_rel204
echo "|          ========================================================           |"    >> $interface_rel204
echo "|          |                                                      |           |"    >> $interface_rel204
echo "|          |                  REL204 - Concluido.                 |           |"    >> $interface_rel204
echo "|          |               Tecle [enter] para sair.               |           |"    >> $interface_rel204
echo "|          |                                                      |           |"    >> $interface_rel204
echo "|          ========================================================           |"    >> $interface_rel204
echo "|                                                                             |"    >> $interface_rel204
echo "|                                                                             |"    >> $interface_rel204
echo "|                                                                             |"    >> $interface_rel204
echo "|                                                                             |"    >> $interface_rel204
echo "|                                                                             |"    >> $interface_rel204
echo "|                                                                             |"    >> $interface_rel204
echo "==============================================================================="    >> $interface_rel204
atualizar_tela
rm $interface_rel204  # Remove dados da Interface do Shell
read; clear
