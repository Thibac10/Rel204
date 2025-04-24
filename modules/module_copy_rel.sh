#!/bin/bash


# ----------------------------
#   DEFINICOES DE DIRETORIOS 
# ----------------------------
gerencial=/files/gerencial/administrativo/Gerencial
sis=/files/gerencial/administrativo/sis
isv=/files/gerencial/administrativo/ISV
relatorios_diario=/files/gerencial/relatorios_diario
bk=/fs1/save/bk
administrativo=/files/gerencial/administrativo
dir_imprimir=/files/gerencial/imprimir
# --------------------------


#    INICIO 
# ----------------------------------------------

# Se nao entrar no BK, encerra o script
cd /fs1/save/bk || exit 1

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
#      Relatorios Diario
# -----------------------------------
cd $relatorios_diario
chmod 777 *
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
mv svd18*csv svd18.f940.csv
mv svd18* svd18.txt
mv svd62*csv svd62.f940.csv
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
mv srt03.f940.geral*csv srt03.f940.diario.csv
mv srt51*.csv srt51.f940.csv

cp Sit23.csv $gerencial
cp Sas22.csv $gerencial
cp svd18.f940.csv $gerencial
cp sas22.txt $administrativo
cp Svda2.csv $gerencial
cp srt51.f940.csv $gerencial 
cp srt50.f940.*.csv $gerencial/srt50.f940.setor.csv

cp srt50.txt $sis/srt50.f940.txt
cp srt36.txt $sis/srt36.f940.txt
cp srt03.f940.diario.csv $sis

# Relatorios Impressoras
cp /files/gerencial/rel940/impressora_gerencia.csv $sis
cp /files/gerencial/rel940/impressora_nfe.csv $sis
cp /files/gerencial/rel940/impressora_rm.csv $sis
