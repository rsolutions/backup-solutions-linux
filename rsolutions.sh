#!/bin/bash

# Usuário do Banco de Dados
USERNAME=backup1

# Local do Banco de Dados
HOSTDB=localhost

# Nome do Banco de Dados a ser efetuado o backup
NOMEDB="ALTERDATA"

# Local de armazenamento dos Backups
BACKUPDIR="/home/backups/"

# Contéudo do E-mail
EMAILCONT="log"

# Tamanho máximo do e-mail em Kb
MAXATTSIZE="4000"

# Endereço de e-mail para recebimento dos relatórios
ENDMAIL="rafaah.psy@gmail.com"

# Nome dos Banco de Dados para armazemanto Mensal
MNOMEDB="template1 $NOMEDB"

# Lista de bancos a serem excluídos no Backup (Deixar em branco, entre "", caso seja realizado para todos os banco de dados)
DBEXCLUDE=""

# Incluir a função de criação de backup nos arquivos
CREATE_DATABASE=yes

# Separar pastas de acordo com o nome do Banco de Dados (yes or no)
SEPDIR=yes

# Em qual dia será realizado o backup semanal? (1 até 7 onde 1 é Segunda-Feira)
DOWEEKLY=6

# Método de compressão (gzip ou bzip2)
COMP=gzip

# Comando a ser realizado antes do backup (remover comentário para realizar o uso da função)
#PREBACKUP="/etc/pgsql-backup-pre"

# Comando a ser realizado após o backup (remover comentário para realizar o uso da função)
#POSTBACKUP="bash /home/backups/scripts/ftp_pgsql"


#================================================= ====================
# Documentação de opções
#================================================= ====================
# Definir USERNAME e PASSWORD de um usuário que tenha pelo menos a permissão SELECT
# para TODOS os bancos de dados.
#
#  CREATE USER autobkp SUPERUSER INHERIT CREATEDB CREATEROLE;
#  GRANT ALL PRIVILEGES ON DATABASE "BANCODEDADOS" TO autobkp;
#
# Defina a opção HOSTDB para o servidor que você deseja fazer backup, deixe o
# padrão para fazer backup "deste servidor" (para fazer backup de vários servidores,
# cópias deste arquivo e defina as opções para esse servidor)
#
# Coloque na lista de NOMEDB (Bancos de dados) para fazer o backup. Se você gostaria
# para fazer backup de todos os bancos de dados no servidor NOMEDB = "all" (se definido como "all",
# quaisquer novos bancos de dados serão automaticamente copiados sem a necessidade de modificar
# este script de backup quando um novo banco de dados é criado).
#
# Se o banco de dados que você deseja fazer backup tiver um espaço no nome, substitua o espaço
# com%, por exemplo "base de dados" se tornará "data% base"
# NOTA: Espaços em nomes DB podem não funcionar corretamente quando SEPDIR = não.
#
# Você pode alterar o local de armazenamento de backup de / backups para qualquer coisa
# você gosta usando a configuração BACKUPDIR.
#
# As opções EMAILCONT e ENDMAIL e bastante auto-explicativas, usam
# para que o log de backup seja enviado para você em qualquer endereço de e-mail ou em vários
# endereços de e-mail em uma lista separada por espaço.
# (Se você definir o conteúdo do email como "log", precisará de acesso ao programa "mail"
# no seu servidor. Se você definir isso para "arquivos", você terá que ter o mutt instalado
# no seu servidor. Se você definir sto stdout, ele será registrado na tela se for executado
# o console ou o proprietário do trabalho cron se executado através do cron)
#
# MAXATTSIZE define o maior número total de anexos de e-mail permitidos (todos os arquivos de backup)
# deseja que o script seja enviado. Este é o tamanho antes de ser codificado para ser enviado como um email
# então, se o seu servidor de e-mail permitir um tamanho máximo de e-mail de 5 MB, eu sugeriria definir
# MAXATTSIZE para ser 25% menor do que isso, então uma configuração de 4000 provavelmente estaria boa.
#
# Finalmente copie o automysqlbackup.sh para qualquer lugar no seu servidor e certifique-se
# para definir permissão executável. Você também pode copiar o script para
# /etc/cron.diario para que seja executado automaticamente todas as noites ou simplesmente
# coloque um symlink em /etc/cron.diario no arquivo, se você quiser mantê-lo
# em outro lugar.
# NOTA: No Debian copie o arquivo sem nenhuma extensão para que ele seja executado
# por cron, por exemplo, apenas nomeie o arquivo "automysqlbackup"
#
# É isso aí..
#
#
# === Docs de opções avançadas ===
#
#
# Se você definir NOMEDB = "all" você pode configurar a opção DBEXCLUDE. De outros sábio esta opção não será usada.
# Esta opção pode ser usada se você quiser fazer backup de todos os dbs, mas você quer
# exclui alguns deles. (por exemplo, um banco de dados é grande).
#
# Configure CREATE_DATABASE para "yes" (o padrão) se você quiser que o seu SQL-Dump crie
# um banco de dados com o mesmo nome do banco de dados original durante a restauração.
# Dizer "não" aqui permitirá que você especifique o nome do banco de dados que deseja
# restaurar o seu despejo, fazendo uma cópia do banco de dados usando o despejo
# criado com automysqlbackup.
#
# Para definir o dia da semana em que você gostaria que o backup semanal acontecesse
# defina a configuração DOWEEKLY, isso pode ser um valor de 1 a 7, em que 1 é segunda-feira,
# O padrão é 6, o que significa que os backups semanais são feitos em um sábado.
#
# COMP é usado para escolher a copmression usada, as opções são gzip ou bzip2.
# bzip2 produzirá arquivos menores, mas é mais pesado e pode levar mais tempo para ser concluído.
#
# Use PREBACKUP e POSTBACKUP para especificar os comandos pré ou pós backup,
# ou scripts para executar tarefas antes ou depois do processo de backup.
#
#
#================================================= ====================
# Rotação de backup
#================================================= ====================
#
# Backups diários são excluídos semanalmente
# Backups semanais são executados por padrão no sábado de manhã quando scripts cron.diario são executados ... Podem ser alterados com a configuração DOWEEKLY
# Backups semanais são excluídos em um ciclo de 5 semanas.
# Backups mensal são executados no primeiro dia do mês.
# Backups mensal NÃO são excluídos automaticamente ...
#
#================================================= ====================
# IMPORTANTE!!!
#================================================= ====================
#
# Não tomo nenhuma responsabilidade por qualquer perda ou falha durante o backup do banco de dados ao usar
# este script ..
# Este script não ajudará no caso de uma falha no disco rígido. Se um
# cópia do backup não foi armazenada offline ou em outro PC.
# Você deve copiar seus backups regularmente para melhor proteção.
#
#================================================= ====================
# Change Log
#================================================= ====================
#
# VER 1.0 - (01-08-2018) - Por Rafael Almeida
# rSOLUTIONS Network
#
#================================================= ====================
#================================================= ====================
#
# Não precisa ser modificado daqui para baixo !!
#
#================================================= ====================
#================================================= ====================
PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/postgres/bin:/usr/local/pgsql/bin
DATE=`date +%Y-%m-%d`				# 2002-09-21
DOW=`date +%A`					# Monday
DNOW=`date +%u`					# Número do dia da semana 1 a 7, em que 1 representa segunda-feira
DOM=`date +%d`					# Data do Mês, por exemplo 27
M=`date +%B`					# Mês, por exemplo, janeiro
W=`date +%V`					# Número da semana, por exemplo, 37
VER=1.0						# Número da versão
LOGFILE=$BACKUPDIR/$HOSTDB-`date +%N`.log	# Nome do arquivo de log
OPT=""						# Opção de uso quando MySQL, em uso do mysqldump
BACKUPFILES=""					# thh: adicionado para posterior envio

# Cria diretórios necessários
if [ ! -e "$BACKUPDIR" ]		# Checa se os directórios existem antes de efetuar a criação.
	then
	mkdir -p "$BACKUPDIR"
fi

if [ ! -e "$BACKUPDIR/diario" ]		
	then
	mkdir -p "$BACKUPDIR/diario"
fi

if [ ! -e "$BACKUPDIR/semanal" ]		
	then
	mkdir -p "$BACKUPDIR/semanal"
fi

if [ ! -e "$BACKUPDIR/mensal" ]	
	then
	mkdir -p "$BACKUPDIR/mensal"
fi


touch $LOGFILE
exec 6>&1 
exec > $LOGFILE

# Funções

# Função de dump do banco de dados
dbdump () {
pg_dump --username=$USERNAME $HOST $OPT $1 > $2
return 0
}

# Função de Compactação do Backup gerado
SUFFIX=""
compression () {
if [ "$COMP" = "gzip" ]; then
	gzip -f "$1"
	echo
	echo Informações de backup para "$1"
	gzip -l "$1.gz"
	SUFFIX=".gz"
elif [ "$COMP" = "bzip2" ]; then
	echo Informações de compactação para "$1.bz2"
	bzip2 -f -v $1 2>&1
	SUFFIX=".bz2"
else
	echo "Nenhuma opção de compactação definida, verifique as configurações avançadas"
fi
return 0
}


#Execute o comando antes de começarmos
if [ "$PREBACKUP" ]
	then
	echo ======================================================================
	echo "Preparação inicial do Backup"
	echo
	eval $PREBACKUP
	echo
	echo ======================================================================
	echo
fi


if [ "$SEPDIR" = "yes" ]; then # Verifique se o CREATE DATABASE deve ser incluído no Dump
	if [ "$CREATE_DATABASE" = "no" ]; then
		OPT="$OPT"
	else
		OPT="$OPT --create"
	fi
else
	OPT="$OPT"
fi

# Nome do host para informações de LOG
if [ "$HOSTDB" = "localhost" ]; then
	HOSTDB="`hostname -f`"
	HOST=""
else
	HOST="-h $HOSTDB"
fi

# Se estiver fazendo backup de todos os bancos de dados no servidor
if [ "$NOMEDB" = "all" ]; then
	NOMEDB="`psql -U $USERNAME $HOST -l -A -F: | sed -ne "/:/ { /Name:Owner/d; /template0/d; s/:.*$//; p }"`"
	
	# Exclusão dos Banco de Dados informados nas configurações
	for exclude in $DBEXCLUDE
	do
		NOMEDB=`echo $NOMEDB | sed "s/\b$exclude\b//g"`
	done

        MNOMEDB=$NOMEDB
fi
	
echo ======================================================================
echo Backup rSOLUTIONS - Network VER $VER
echo rsolutionsnetwork@gmail.com
echo Rafael Almeida - 62 99942-4108
echo Backup do servidor de banco de dados - $HOSTDB
echo ======================================================================

# Verificar se o backup será separado por pastas
if [ "$SEPDIR" = "yes" ]; then
echo Hora de início do backup `date`
echo ======================================================================
	# Backup completo mensal de todos os bancos de dados
	if [ $DOM = "01" ]; then
		for MDB in $MNOMEDB
		do
 
			 # Prepara $DB para o uso.
		        MDB="`echo $MDB | sed 's/%/ /g'`"

			if [ ! -e "$BACKUPDIR/mensal/$MDB" ]		# Verifica os backups mensal
			then
				mkdir -p "$BACKUPDIR/mensal/$MDB"
			fi
			echo Backup mensal de $MDB...
				dbdump "$MDB" "$BACKUPDIR/mensal/$MDB/${MDB}_$DATE.$M.$MDB.sql"
				compression "$BACKUPDIR/mensal/$MDB/${MDB}_$DATE.$M.$MDB.sql"
				BACKUPFILES="$BACKUPFILES $BACKUPDIR/mensal/$MDB/${MDB}_$DATE.$M.$MDB.sql$SUFFIX"
			echo ----------------------------------------------------------------------
		done
	fi

	for DB in $NOMEDB
	do
	# Preparando $DB para uso
	DB="`echo $DB | sed 's/%/ /g'`"
	
	# Criar diretório separado para cada banco de dados
	if [ ! -e "$BACKUPDIR/diario/$DB" ]		# Verifique se existe o caminho diário do DB.
		then
		mkdir -p "$BACKUPDIR/diario/$DB"
	fi
	
	if [ ! -e "$BACKUPDIR/semanal/$DB" ]		
		then
		mkdir -p "$BACKUPDIR/semanal/$DB"
	fi
	
	# Backup Semanal
	if [ $DNOW = $DOWEEKLY ]; then
		echo Backup semanal de banco de dados \( $DB \)
		echo Será excluído backups de 5 semanas atrais...
			if [ "$W" -le 05 ];then
				REMW=`expr 48 + $W`
			elif [ "$W" -lt 15 ];then
				REMW=0`expr $W - 5`
			else
				REMW=`expr $W - 5`
			fi
		eval rm -fv "$BACKUPDIR/semanal/$DB/week.$REMW.*" 
		echo
			dbdump "$DB" "$BACKUPDIR/semanal/$DB/${DB}_week.$W.$DATE.sql"
			compression "$BACKUPDIR/semanal/$DB/${DB}_week.$W.$DATE.sql"
			BACKUPFILES="$BACKUPFILES $BACKUPDIR/semanal/$DB/${DB}_week.$W.$DATE.sql$SUFFIX"
		echo ----------------------------------------------------------------------
	
	# Backup diário
	else
		echo Backup diário de banco de dados \( $DB \)
		echo Rotacionando as últimas semanas...
		eval rm -fv "$BACKUPDIR/diario/$DB/*.$DOW.sql.*" 
		echo
			dbdump "$DB" "$BACKUPDIR/diario/$DB/${DB}_$DATE.$DOW.sql"
			compression "$BACKUPDIR/diario/$DB/${DB}_$DATE.$DOW.sql"
			BACKUPFILES="$BACKUPFILES $BACKUPDIR/diario/$DB/${DB}_$DATE.$DOW.sql$SUFFIX"
		echo ----------------------------------------------------------------------
	fi
	done
echo Backup finalizado `date`
echo ======================================================================


else # Um arquivo de backup para todos os bancos de dados
echo Iniciado o backup de `date`
echo ======================================================================
	# Meses de Backup Completo de todos os Bancos de Dados
	if [ $DOM = "01" ]; then
		echo Backup completo mensal de \( $MNOMEDB \)...
			dbdump "$MNOMEDB" "$BACKUPDIR/mensal/$DATE.$M.all-databases.sql"
			compression "$BACKUPDIR/mensal/$DATE.$M.all-databases.sql"
			BACKUPFILES="$BACKUPFILES $BACKUPDIR/mensal/$DATE.$M.all-databases.sql$SUFFIX"
		echo ----------------------------------------------------------------------
	fi

	# Backup semanal
	if [ $DNOW = $DOWEEKLY ]; then
		echo Backup semanal de bancos de dados \( $NOMEDB \)
		echo
		echo Rotacionando 5 semanas de backups ...
			if [ "$W" -le 05 ];then
				REMW=`expr 48 + $W`
			elif [ "$W" -lt 15 ];then
				REMW=0`expr $W - 5`
			else
				REMW=`expr $W - 5`
			fi
		eval rm -fv "$BACKUPDIR/semanal/week.$REMW.*" 
		echo
			dbdump "$NOMEDB" "$BACKUPDIR/semanal/week.$W.$DATE.sql"
			compression "$BACKUPDIR/semanal/week.$W.$DATE.sql"
			BACKUPFILES="$BACKUPFILES $BACKUPDIR/semanal/week.$W.$DATE.sql$SUFFIX"
		echo ----------------------------------------------------------------------
		
	# Backup Diário
	else
		echo Backup diário do Bancos de Dados \( $NOMEDB \)
		echo
		echo Rotacionando o backup da semana passada ...
		eval rm -fv "$BACKUPDIR/diario/*.$DOW.sql.*" 
		echo
			dbdump "$NOMEDB" "$BACKUPDIR/diario/$DATE.$DOW.sql"
			compression "$BACKUPDIR/diario/$DATE.$DOW.sql"
			BACKUPFILES="$BACKUPFILES $BACKUPDIR/diario/$DATE.$DOW.sql$SUFFIX"
		echo ----------------------------------------------------------------------
	fi
echo Backup finalizado em `date`
echo ======================================================================
fi
echo Espaço total em disco usado para armazenamento de backup.
echo Tamanho - Localização
echo `du -hs "$BACKUPDIR"`
echo


# Executar o comando após o backup
if [ "$POSTBACKUP" ]
	then
	echo ======================================================================
	echo "Backup finalizado, agora será executado os "
	echo
	eval $POSTBACKUP
	echo
	echo ======================================================================
fi

#Limpar o redirecionamento de IO
exec 1>&6 6>&-

if [ "$EMAILCONT" = "files" ]
then
	#Obter o tamanho do backup
	ATTSIZE=`du -c $BACKUPFILES | grep "[[:digit:][:space:]]total$" |sed s/\s*total//`
	if [ $MAXATTSIZE -ge $ATTSIZE ]
	then
		BACKUPFILES=`echo "$BACKUPFILES" | sed -e "s# # -a #g"`	#ativar vários anexos
		mutt -s "Registro de backup do PostgreSQL e arquivos SQL para $HOSTDB - $DATE" $BACKUPFILES $ENDMAIL < $LOGFILE		#Enviando via mutt
	else
		cat "$LOGFILE" | mail -s "ATENÇÃO! - O backup do PostgreSQL excede o tamanho máximo de anexos $HOST - $DATE" $ENDMAIL
	fi
elif [ "$EMAILCONT" = "log" ]
then
	cat "$LOGFILE" | mail -s "Log de backup do PostgreSQL para $HOSTDB - $DATE" $ENDMAIL
else
	cat "$LOGFILE"
fi

# Limpar o arquivo de log
eval rm -f "$LOGFILE"

exit 0
