#!/bin/bash

## Arquivos necessários para execução Shell REL940
# • imprimir
# • email940
# • module_copy_rel.sh

# Parâmetros de execução:
# -noemail  :: Executa o rel940 sem e'mails.
# -noprint  :: Executa o rel940 sem impressões.
#
# Ex. rel940 -noemail -noprint

version="V1.8.0"

#############  Variáveis Globais  ###########################
#  !! Não alterar as variáveis globais !!

data=$(date "+%d%m%y")   # NAO ALTERAR
send_email=1             # NAO ALTERAR
send_printer=1           # NAO ALTERAR

DIA_HOJE=`date +'%d'`
HORA_HOJE=`date +'%H'`

#ID_USUARIO_LOGADO=`whoami`

if [[ $HORA_HOJE -lt 10 ]];
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

# ----------------------------
#   DEFINICOES DE DIRETORIOS 
# ----------------------------

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
# --------------------------

## Variáveis de Funcionamento do SHELL
log_rel940=$(echo /files/gerencial/rel940/log/rel940_$data.log)
interface_rel940=/files/gerencial/rel940/rel940_interface
dir_rel940=/files/gerencial/rel940

# Reinicialização Mensal para relatório Impressões
if [ $DIA_HOJE -eq 02 ];
  then

  data_001=$(tail -n 1 $dir_rel940/impressora_gerencia.csv);
  data_002=$(tail -n 1 $dir_rel940/impressora_nfe.csv);
  data_003=$(tail -n 1 $dir_rel940/impressora_rm.csv);
  
  # Cria estrutura
  line_1="Data;Folhas impressas;Paginas impressas;";
  
  echo $line_1 > $dir_rel940/impressora_gerencia.csv;
  echo " " >> $dir_rel940/impressora_gerencia.csv;
  
  echo $line_1 > $dir_rel940/impressora_nfe.csv;
  echo " " >> $dir_rel940/impressora_nfe.csv;
  
  echo $line_1 > $dir_rel940/impressora_rm.csv;
  echo " " >> $dir_rel940/impressora_rm.csv;
  
  # Define valores de inicializacao do mes
  echo "initiation//;${data_001:11:20}" >> $dir_rel940/impressora_gerencia.csv;
  echo " " >> $dir_rel940/impressora_gerencia.csv;
  
  echo "initiation//;${data_002:11:20}" >> $dir_rel940/impressora_nfe.csv;
  echo " " >> $dir_rel940/impressora_nfe.csv;
  
  echo "initiation//;${data_003:11:20}" >> $dir_rel940/impressora_rm.csv;
  echo " " >> $dir_rel940/impressora_rm.csv;

fi

############## FUNÇÕES  #############################

atualizar_tela() { 
  # SINTAXE : atualizar_tela [mensagem_temporaria] 
  
  # Obs.: O parametro 'mensagem_temporaria' não é obrigatório.
  mensagem_temporaria=$1

  if [ $# -eq 1 ]; then
    clear
    more $interface_rel940
    echo -e "$mensagem_temporaria";
  else
    clear
    more $interface_rel940  
  fi
}

exe() { 
  # A funcao 'exe' executa um comando em segundo plano e continua a execucao do script
  # SINTAXE:  exe [comando] [descricao]   --

  # EXEMPLO:
  # exe 'cp arquivo.txt /home' 'Copiando arquivo para o \/home'

  echo "Iniciado Execucao: '$1' --> [ $(date "+%d/%m/%y %H:%M:%S") ]" >> $log_rel940

  if [ $# -eq 2 ]; then
    nohup $1 >> $log_rel940 &
    echo "$2" >> $interface_rel940
    atualizar_tela
  else
    nohup $1 >> $log_rel940 &
    atualizar_tela
  fi
}

rel_impressora() { 
  
  atualizar_tela '   - Verificando numero de impressoes...'

  # Gerencia
  exe 'wget http://10.120.232.21/cgi-bin/dynamic/printer/config/reports/devicestatistics.html'
  nohup wget http://10.120.232.21/cgi-bin/dynamic/printer/config/reports/devicestatistics.html >> $log_rel940 &
  wget http://10.120.232.21/cgi-bin/dynamic/printer/config/reports/devicestatistics.html >> $log_rel940
  atualizar_tela '   - Verificando numero de impressoes...'
  wait
  sleep 2
  folhas=$(cat devicestatistics.html | grep -n ^ | grep ^72)
  paginas=$(cat devicestatistics.html | grep -n ^ | grep ^97)
  echo "$date;${folhas:73:9};${paginas:73:9};" >> $dir_rel940/impressora_gerencia.csv
  echo "$date;${folhas:73:9};${paginas:73:9};" >> $dir_rel940/impressora_gerencia_historico.csv
  rm devicestatistics.html
  folhas=""; paginas="";
  
  # RM
  exe 'wget http://10.120.232.22/cgi-bin/dynamic/printer/config/reports/devicestatistics.html'
  nohup wget http://10.120.232.22/cgi-bin/dynamic/printer/config/reports/devicestatistics.html >> $log_rel940 &
  wget http://10.120.232.22/cgi-bin/dynamic/printer/config/reports/devicestatistics.html >> $log_rel940
  atualizar_tela '   - Verificando numero de impressoes...'
  wait
  sleep 2
  folhas=$(cat devicestatistics.html | grep -n ^ | grep ^70)
  paginas=$(cat devicestatistics.html | grep -n ^ | grep ^111)
  echo "$date;${folhas:73:9};${paginas:74:9};" >> $dir_rel940/impressora_rm.csv
  echo "$date;${folhas:73:9};${paginas:74:9};" >> $dir_rel940/impressora_rm_historico.csv
  rm devicestatistics.html
  folhas=""; paginas="";
  
  # Caixa empresa
  exe 'wget http://10.120.232.24/cgi-bin/dynamic/printer/config/reports/devicestatistics.html'
  nohup wget http://10.120.232.24/cgi-bin/dynamic/printer/config/reports/devicestatistics.html >> $log_rel940 &
  wget http://10.120.232.24/cgi-bin/dynamic/printer/config/reports/devicestatistics.html >> $log_rel940
  atualizar_tela '   - Verificando numero de impressoes...'
  wait
  sleep 2
  folhas=$(cat devicestatistics.html | grep -n ^ | grep ^72)
  paginas=$(cat devicestatistics.html | grep -n ^ | grep ^107)
  echo "$date;${folhas:73:9};${paginas:74:9};" >> $dir_rel940/impressora_nfe.csv
  echo "$date;${folhas:73:9};${paginas:74:9};" >> $dir_rel940/impressora_nfe_historico.csv
  rm devicestatistics.html
  
  echo "   - Verificado numero de impressoes: Gerencia, RM e Caixa Empresa." >> $interface_rel940
  echo " " >> $interface_rel940
}

gerar_rel(){ 
  cd /fs1/save/
  #echo -e "\n   Gerando $descricao [...]";
  
  # Organizacao do Log - Para melhor visualizacao/conferencia das informacoes
  echo -e "=================================================================================================" >> $log_rel940;
  echo -e "\n[ $descricao ]" >> $log_rel940;
  
  # Execucao
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
  echo "   - $descricao Gerado." >> $interface_rel940
  atualizar_tela
}

generate_rel(){ 
  cd /fs1/save/ || { echo "generate_rel ::: Falha ao acessar o diretorio /fs1/save/" >> $log_rel940; return 1; }
  
  local descricao=$1
  local parametro=$2
  local nome_arq_bk=$3
  local destino_1=$4
  local destino_2=$5
  local impressao=$6
  
  # Organizacao do Log - Para melhor visualizacao/conferencia das informacoes
  echo -e "=================================================================================================" >> $log_rel940;
  echo -e "\n[ $descricao ]" >> $log_rel940;
  
  # Execucao
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
  echo "   - $descricao Gerado." >> $interface_rel940
  atualizar_tela
}

limpeza_antes_rel(){ 
  
  # REGISTRANDO LISTAGEM DE ARQUIVOS NO BK -> LOG REL940
  echo -e "\n     LISTA DE ARQUIVOS NO DIRETORIO BK       \n============================================" >> $log_rel940
  ls -l >> $log_rel940

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
  echo "===============================================================================" > $interface_rel940
  echo "|                                                                             |" >> $interface_rel940
  echo "|               REL940 - Desenvolvido por CPD Mogi das Cruzes                 |" >> $interface_rel940
  echo "|----------------------------------------------------------------- [$version] --|" >> $interface_rel940
  for line in {1..6}; do 
    echo "|                                                                             |" >> $interface_rel940;
  done
  echo "|          +-[ INFO ]---------------------------------------------+           |" >> $interface_rel940
  echo "|          |                                                      |           |" >> $interface_rel940
  echo "|          |                                                      |           |" >> $interface_rel940
  echo "|          |                                                      |           |" >> $interface_rel940
  echo "|          +------------------------------------------------------+           |" >> $interface_rel940
  for line in {1..7}; do 
    echo "|                                                                             |" >> $interface_rel940;
  done
  echo "===============================================================================" >> $interface_rel940
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
  
  echo -e "\n :::: Saida da chamada : \"$1\" ::::\n" >> $log_rel940
  clear
  echo "===============================================================================" > $interface_rel940
  echo "|                                                                             |" >> $interface_rel940
  echo "|               REL940 - Desenvolvido por CPD Mogi das Cruzes                 |" >> $interface_rel940
  echo "|----------------------------------------------------------------- [$version] --|" >> $interface_rel940
  for line in {1..6}; do 
    echo "|                                                                             |" >> $interface_rel940;
  done
  echo "|          +-[ INFO ]---------------------------------------------+           |" >> $interface_rel940
  echo "|          |                                                      |           |" >> $interface_rel940
  echo "|          |                                                      |           |" >> $interface_rel940
  echo "|          |                                                      |           |" >> $interface_rel940
  echo "|          +------------------------------------------------------+           |" >> $interface_rel940
  for line in {1..7}; do 
    echo "|                                                                             |" >> $interface_rel940;
  done
  echo "===============================================================================" >> $interface_rel940
  echo "Iniciado Shell: '$1' --> [ $(date "+%d/%m/%y %H:%M:%S") ]" >> $log_rel940
  nohup $1 >> $log_rel940 &
  atualizar_tela
  tput cup 12 $NCarac_left
  echo $texto_a_ser_apresentado
  tput cup 23 0
  sleep 2;
  wait
}

####################### SEQUENCIA SHELL ######################################

cd /fs1/save/
clear
echo "===============================================================================" > $interface_rel940
echo "|                                                                             |" >> $interface_rel940
echo "|               REL940 - Desenvolvido por CPD Mogi das Cruzes                 |" >> $interface_rel940
echo "|----------------------------------------------------------------- [$version] --|" >> $interface_rel940
echo "|          Relatorios sendo gerados para atualizacao do Gerencial             |" >> $interface_rel940
echo "===============================================================================" >> $interface_rel940
echo "" >> $interface_rel940
check_exe_email_impressao >> $interface_rel940
echo "   - Excluido: - Relatorios do BK." >> $interface_rel940
echo "               - Arquivos do diretorio Gerencial." >> $interface_rel940
echo " " >> $interface_rel940
#rel_impressora
atualizar_tela
limpeza_antes_rel # Limpeza antes de gerar os relatórios.

######################  GERAR RELATORIOS  ###################################

########################  DATA ATUAL  #######################################

## *** Todas as variáveis devem estar preenchidas para cada relatório. *** ##
## Exemplo de relatório:
## descricao="SAEBI51 - [Ajuste]"; parametro="dfrun exe saebi51 1 940 0 010151 010151 0 1 0 0"; nome_arq_bk="sae51*.csv"; destino_1=$Gerencial; destino_2="null"; impressao="yes";
## No exemplo acima será gerado o relatório SAEBI51 e seu arquivo gerado "sae51*.csv" será copiado para o Gerencial, tendo uma cópia tambem na pasta imprimir. 
## Após preechimentos das variáveis executa-se a função "gerar_rel".

#descricao="SAEBI51 - [Relatorio 1]"; parametro="dfrun exe saebi51 1 940 0 010151 010151 0 1 0 0"; nome_arq_bk="sae51*.csv"; destino_1=$gerencial; destino_2="null"; impressao="no";
#gerar_rel
#rm /fs1/save/bk/sae51*

#descricao="SAEBI51 - [Relatorio 2]"; parametro="dfrun exe saebi51 1 940 0 010151 010151 0 2 0 0"; nome_arq_bk="sae51*.csv"; destino_1=$gerencial; destino_2="null"; impressao="no";
#gerar_rel
#rm /fs1/save/bk/sae51*

#descricao="SAEBI51 - [Relatorio 3]"; parametro="dfrun exe saebi51 1 940 0 010151 010151 0 3 0 0"; nome_arq_bk="sae51*.csv"; destino_1=$gerencial; destino_2="null"; impressao="no";
#gerar_rel
#rm /fs1/save/bk/sae51*

#descricao="SAEBI51 - [Relatorio 4]"; parametro="dfrun exe saebi51 1 940 0 010151 010151 0 4 0 0"; nome_arq_bk="sae51*.csv"; destino_1=$gerencial; destino_2="null"; impressao="no";
#gerar_rel
#rm /fs1/save/bk/sae51*

# Concatenando relatórios - SAEBI51
#cd $gerencial
#cat sae51*.csv > sae51.f940.csv

# descricao="SAEBI60"; parametro="dfrun exe saebi60 1 940 0 010151 010151 9999 0 0 1"; nome_arq_bk="sae60*.csv"; destino_1=$gerencial/sae60.f940.csv; destino_2="null"; impressao="no";
# gerar_rel
cp $dir_rel940/base_temporaria/sae60.f940.csv $gerencial/sae60.f940.csv

descricao="SRTBI51"; parametro="dfrun exe srtbi51 1 940 0 010121 010121 1 3 0 0"; nome_arq_bk="srt51*"; destino_1=$relatorios_diario; destino_2="null"; impressao="no";
gerar_rel

descricao="SRMBI02"; parametro="dfrun exe srmbi02 1 940 0 010121 010121 0 0 999 801"; nome_arq_bk="srm02*.csv"; destino_1=$gerencial/srm02.f940.csv; destino_2="null"; impressao="no";
gerar_rel

descricao="SRTBI36"; parametro="dfrun exe srtbi36 1 940 0 010121 010121 1 9999 2 2"; nome_arq_bk="srt36*.csv"; destino_1=$gerencial/srt36.f940.csv; destino_2="null"; impressao="no";
gerar_rel

descricao="SVDBI08"; parametro="dfrun exe svdbi08 1 940 0 010121 010121 2 0 1 9999"; nome_arq_bk="svd08_mensal*"; destino_1=$relatorios_diario; destino_2="null"; impressao="no";
gerar_rel

# descricao="SMGBI23"; parametro="dfrun exe smgbi23 1 940 0 010121 010121 0 0 1 1"; nome_arq_bk="smg23*.csv"; destino_1=$gerencial/smg23.f940.csv; destino_2="null"; impressao="no";
# gerar_rel # Gerado no Batch
cp $bk/smg23*.csv $gerencial/smg23.f940.csv

# descricao="SMGBI11"; parametro="dfrun exe smgbi11 1 940 0 010121 010121 1 1 0 0"; nome_arq_bk="smg11*.csv"; destino_1=$gerencial/smg11.f940.csv; destino_2="null"; impressao="no";
# gerar_rel # Gerado no Batch
# cp $bk/smg11*.csv $gerencial/smg11.f940.csv

# descricao="SVDBI04"; parametro="dfrun exe svdbi04 1 940"; nome_arq_bk="svd04*"; destino_1="null"; destino_2="null"; impressao="no";
# gerar_rel

# Usado em: Planilha Geral > LUCRO MENSAL
descricao="SRTBI03 - [Geral]"; parametro="dfrun exe srtbi03 1 940 0 010121 010121 0 0 0 1"; nome_arq_bk="srt03*.csv"; destino_1=$gerencial/srt03.f940.geral.csv; destino_2=$sis/srt03.f940.geral.csv; impressao="no";
gerar_rel
rm /fs1/save/bk/srt03*

# Gerado no Batch
#cp $bk/smg12.*csv $isv/smg12.csv

########################  DATA ANTERIOR  #######################################

## *** Todas as variáveis devem estar preenchidas para cada relatório. *** ##
## Exemplo de relatório:
## descricao="SAEBI51 - [Ajuste]"; parametro="dfrun exe saebi51 1 940 0 010151 010151 0 1 0 0"; nome_arq_bk="sae51*.csv"; destino_1=$Gerencial; destino_2="null"; impressao="yes";
## No exemplo acima será gerado o relatório SAEBI51 e seu arquivo gerado "sae51*.csv" será copiado para o Gerencial, tendo uma cópia tambem na pasta imprimir. 
## Após preechimentos das variáveis executa-se a função "gerar_rel".
clear
echo "===============================================================================" > $interface_rel940
echo "|                                                                             |" >> $interface_rel940
echo "|               REL940 - Desenvolvido por CPD Mogi das Cruzes                 |" >> $interface_rel940
echo "|----------------------------------------------------------------- [$version] --|" >> $interface_rel940
echo "|          Relatorios sendo gerados para atualizacao do Gerencial             |" >> $interface_rel940
echo "===============================================================================" >> $interface_rel940
echo " " >> $interface_rel940
echo "   [ Alteracao da data batch para o dia anterior ]" >> $interface_rel940
echo " "  >> $interface_rel940 
atualizar_tela
sleep 3

dfrun exe sadou09
atualizar_tela

# Diario - Loja
descricao="SRTBI03 - [Relatorio 1]"; parametro="dfrun exe srtbi03 1 940 0 010121 010121 0 0 0 0"; nome_arq_bk="srt03*"; destino_1=$relatorios_diario; destino_2="null"; impressao="no";
gerar_rel
rm /fs1/save/bk/srt03*

# descricao="SRTBI03 - [Relatorio 2]"; parametro="dfrun exe srtbi03 1 940 0 010121 010121 0 0 1 0"; nome_arq_bk="srt03.*"; destino_1="null"; destino_2="null"; impressao="no";
# gerar_rel

# Cafeteria Diário
descricao="SRTBI03 - [Cafeteria - Diario]"; parametro="dfrun exe srtbi03 1 940 0 010121 010121 1 0 1 0"; nome_arq_bk="srt03*"; destino_1="null"; destino_2="null"; impressao="no";
gerar_rel

#descricao="SAEBI51 - [Avaria]"; parametro="dfrun exe saebi51 1 940 0 010151 010151 7 1 0 3"; nome_arq_bk="sae51.f940.avaria*.csv"; destino_1=$sis/sae51.f940.avaria.csv; destino_2="null"; impressao="no";
#gerar_rel

#descricao="SAEBI51 - [Ajuste]"; parametro="dfrun exe saebi51 1 940 0 010151 010151 7 2 0 3"; nome_arq_bk="sae51.f940.ajuste*.csv"; destino_1=$sis/sae51.f940.ajuste.csv; destino_2="null"; impressao="no";
#gerar_rel

descricao="SRTBI50 - [Relatorio 1]"; parametro="dfrun exe srtbi50 1 940 0 010121 010121 0 0 0 0 2"; nome_arq_bk="srt50*.csv"; destino_1=$gerencial/srt50.f940.csv; destino_2="null"; impressao="no";
gerar_rel
# rm /fs1/save/bk/srt50*

# descricao="SRTBI50 - [Relatorio 2]"; parametro="dfrun exe srtbi50 1 940 0 010121 010121 0 0 0 0"; nome_arq_bk="srt50*"; destino_1="null"; destino_2="null"; impressao="no";
# gerar_rel

# descricao="SAEBI17"; parametro="dfrun exe saebi17 1 940 0 010108 010108 0 999 0 0"; nome_arq_bk="sae17*"; destino_1="null"; destino_2="null"; impressao="no";
# gerar_rel

# DESATIVADO - Anteriormente enviado por e-mail
# descricao="SCDBI61 - [NC]"; parametro="dfrun exe scdbi61 1 940 0 010121 010121 1 1 1 1"; nome_arq_bk="scd61*"; destino_1="null"; destino_2="null"; impressao="no";
# gerar_rel

#descricao="SVDBI02"; parametro="dfrun exe svdbi02 1 940"; nome_arq_bk="svd02*"; destino_1="null"; destino_2="null"; impressao="no";
#gerar_rel

#############################  FINAL RELATORIOS DIA ANTERIOR   #############################


echo -e "\n   [ Alteracao da data batch para o dia atual ]" >> $interface_rel940
echo " "  >> $interface_rel940
atualizar_tela
sleep 3
dfrun exe sadou09

msg_box 'Relatorios Gerados.' 3
#exe_shell 'module_copy_rel.sh' 'COPIANDO ARQUIVOS --> relatorios_diario' 
exe_shell 'bash /files/gerencial/rel940/modules/module_copy_rel.sh' 'COPIANDO ARQUIVOS --> relatorios_diario' 

# ---------------------------------------------
#      Copiando do BK para relatorios diario
# ---------------------------------------------

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
  exe_shell 'email940' 'Enviando relatorios por email...'
fi

msg_box 'Copiando relatorios para impressao...' 2
cd $bk

# Contabilidade
cp svd08_diario.f940* $dir_imprimir
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
cp srt03.f940.cafet_diario* $dir_imprimir
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

# Gerando relatórios de rentabilidade e avaria para gerência
#exe_shell 'python /files/cpd/shell/rel-avaria.py' 'Gerando Relatorio de avaria [...]'
#exe_shell 'python /files/cpd/shell/rel-rentabilidade.py' 'Gerando Relatorio de rentabilidade [...]'
# Dando permissão total para os relatórios que foram gerandos para gerência (Avaria e Rentabilidade)
chmod 777 /files/gerencial/relatorios_diario/final*
# Gerando relatório de classe de vendas para gerência para impressão
#exe_shell 'classe-imprimir.sh' 'Gerando PDF classe para imprimir [...]'
# Dando permissão total para relatório classe.pdf
#chmod 777 /files/gerencial/relatorios_diario/classe.pdf

if [ $send_printer == 1 ];
  then
  exe_shell 'imprimir' 'Imprimindo relatorios...'
fi

exe_shell 'diario' 'Gerando base p/ Relatorio geral...'
exe_shell 'classe.sh' 'Executando Shell Classe.sh [...]'
exe_shell 'prevencao.sh' 'Executando Shell Prevencao.sh [...]'
exe_shell 'resultados.sh' 'Executando Shell Resultados.sh [...]'
exe_shell 'diferenca.sh' 'Executando Shell Diferenca.sh [...]'
dados.sh --update
exe_shell 'bkbk' 'Realizando Backup do BK [...]'
exe_shell 'dados.sh --send' 'Enviando email para postagem no CPD Informacoes'

# SMGOI12 :: Verifica se SMGOI12 ja foi gerada
#         +-> Copia se houver arquivo. Inicia SMGOI12 se nao houver.
cd /fs1/save/bk
arquivoSmg12CSV="$(ls -1rt smg12.f940.*[0-9].csv 2>/dev/null | tail -n 1)"
[ ! -f "$arquivoSmg12CSV" ] && cd /fs1/save && dfrun exe smgoi12
sleep 2
smg12.sh
exe_shell 'bash /files/gerencial/rel940/modules/module_gerenciamento_estoque.sh' 'Atualizando Gerenciamento de Estoque [...]'

clear
echo "===============================================================================" > $interface_rel940
echo "|                                                                             |" >> $interface_rel940
echo "|               REL940 - Desenvolvido por CPD Mogi das Cruzes                 |" >> $interface_rel940
echo "|----------------------------------------------------------------- [$version] --|" >> $interface_rel940
echo "|                                                                             |" >> $interface_rel940
echo "|                                                                             |" >> $interface_rel940
echo "|                                                                             |" >> $interface_rel940
echo "|                                                                             |" >> $interface_rel940
echo "|                                                                             |" >> $interface_rel940
echo "|                                                                             |" >> $interface_rel940
echo "|          ========================================================           |" >> $interface_rel940
echo "|          |                                                      |           |" >> $interface_rel940
echo "|          |                  REL940 - Concluido.                 |           |" >> $interface_rel940
echo "|          |               Tecle [enter] para sair.               |           |" >> $interface_rel940
echo "|          |                                                      |           |" >> $interface_rel940
echo "|          ========================================================           |" >> $interface_rel940
echo "|                                                                             |" >> $interface_rel940
echo "|                                                                             |" >> $interface_rel940
echo "|                                                                             |" >> $interface_rel940
echo "|                                                                             |" >> $interface_rel940
echo "|                                                                             |" >> $interface_rel940
echo "|                                                                             |" >> $interface_rel940
echo "===============================================================================" >> $interface_rel940
atualizar_tela
rm $interface_rel940  # Remove dados da Interface do Shell
read; clear
