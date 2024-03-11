#!/bin/bash
#
#
D_PATH=""
REF_DIR=""
CURR_PATH="$(pwd)"
#
declare -a VIRUSES_AVAILABLE=("B19V" "BuV" "CuV" "HBoV" "AAV" "BKPyV" "JCPyV" "KIPyV"
                    "WUPyV" "MCPyV" "HPyV6" "HPyV7" "TSPyV" "HPyV9" "MWPyV"
                    "STLPyV" "HPyV12" "NJPyV" "LIPyV" "SV40" "TTV" "TTVmid"
                    "TTVmin" "HAV" "HBV" "HCV" "HDV" "HEV" "SENV" "HPV2"
                    "HPV6" "HPV11" "HPV16" "HPV18" "HPV31" "HPV39" "HPV45"
                    "HPV51" "HPV56" "HPV58" "HPV59" "HPV68" "HPV77" "HSV-1"
                    "HSV-2" "VZV" "EBV" "HCMV" "HHV6" "HHV7" "KSHV" "ReDoV"
                    "VARV" "MPXV" "EV" "SARS2" "HERV" "MT");
#
################################################################################
#
SHOW_MENU () {
  echo " ----------------------------------------------------------------------------  ";
  echo "                                                                               ";
  echo " OAWK_evaluation.sh : Evaluation for the consensus sequences provided by OAWK. ";
  echo "                                                                               ";
  echo "                                                                               ";
  echo " Program options ------------------------------------------------------------- ";
  echo "                                                                               ";
  echo " -h, --help                                 Show this,                         ";
  echo "                                                                               ";
  echo " -r <STR>, --dir-reference <STR>            Directory containing the references";
  echo "                                            for the reconstruction,            ";
  echo "                                                                               ";
  echo " -o <STR>, --dir-reconstructed <STR>        Directory where the results of     ";
  echo "                                            the reconstruction are stored.     ";
  echo "                                                                               ";
  echo " In the reference directory the files must be named one of the following       ";
  echo " options - \"B19V\" \"BuV\" \"CuV\" \"HBoV\" \"AAV\" \"BKPyV\" \"JCPyV\" \"KIPyV\" \"WUPyV\" ";
  echo " \"MCPyV\" \"HPyV6\" \"HPyV7\" \"TSPyV\" \"HPyV9\" \"MWPyV\" \"STLPyV\" \"HPyV12\" \"NJPyV\" ";
  echo " \"LIPyV\" \"SV40\" \"TTV\" \"TTVmid\" \"TTVmin\" \"HAV\" \"HBV\" \"HCV\" \"HDV\" \"HEV\"    ";
  echo " \"SENV\" \"HPV2\" \"HPV6\" \"HPV11\" \"HPV16\" \"HPV18\" \"HPV31\" \"HPV39\" \"HPV45\"      "; 
  echo " \"HPV51\" \"HPV56\" \"HPV58\" \"HPV59\" \"HPV68\" \"HPV77\" \"HSV-1\" \"HSV-2\" \"VZV\"     ";
  echo " \"EBV\" \"HCMV\" \"HHV6\" \"HHV7\" \"KSHV\" \"ReDoV\" \"VARV\" \"MPXV\" \"EV\" \"SARS2\"    ";
  echo " \"HERV\" \"MT\"                                                               ";
  echo "                                                                               ";
  echo " Example --------------------------------------------------------------------- ";
  echo "                                                                               ";
  echo " ./Evaluation.sh -r reference -o out_analysis                                  ";
  echo "                                                                               ";
  echo " ----------------------------------------------------------------------------- ";
  }
#
################################################################################
#
if [[ "$#" -lt 1 ]];
  then
  HELP=1;
fi
#
POSITIONAL=();
#
while [[ $# -gt 0 ]]
  do
  i="$1";
  case $i in
    -h|--help|?)
      HELP=1;
      shift
    ;;
    -r|--ref|--reference)
      REF_FILE="$2";
      shift 2;
    ;;
    -o|--out|--reconstructed|--consensus)
      file="$2";
      shift 2;
    ;;
    -*) # unknown option with small
    echo "Invalid arg ($1)!";
    echo "For help, try: ./Evaluation.sh -h"
    exit 1;
    ;;
  esac
done
#
set -- "${POSITIONAL[@]}" # restore positional parameters
#
################################################################################
#
if [[ "$HELP" -eq "1" ]];
  then
  SHOW_MENU;
  exit;
fi
#
################################################################################
#
if [[ -f "$REF_FILE" ]] && [[ -f "$file" ]];
  then
  
  printf "Ref. directory - $REF_DIR\nDirectory with reconstructed files - $D_PATH\n\n"
  
  eval "$(conda shell.bash hook)"
  conda activate evaluation
  rm -rf Results
  mkdir Results
  #
  CONSENSUS="$(pwd)/$D_PATH/consensus"

  #Create the .tsv file
  #echo "$file	$name_vir_ref	$k_val	$SNPS	$IDEN	$NCSD	$NRC	$SUM_LEN	$MIN_LEN	$MAX_LEN	$AVG_LEN	$SUM_LEN_WOUT_N	$MIN_LEN_WOUT_N	$MAX_LEN_WOUT_N	$AVG_LEN_WOUT_N" >> Results/total_stats_k.tsv 
  echo "File	Virus	K values	SNPs	AvgIdentity	NCSD	NRC	Reconstructed bases	Minimum contig length	Maximum contig length	Average contig length	Reconstructed bases without N	Minimum contig length without N	Maximum contig length without N	Average contig length without N" > Results/total_stats_k.tsv

      
      tmp_nvr="$(echo $REF_FILE | awk -F/ '{print $NF}')"
      name_vir_ref="$(cut -d'.' -f1 <<< $tmp_nvr)"
    
      tmp_nvrecon="$(echo $file | awk -F/ '{print $NF}')"
      name_vir_recon="$(cut -d'-' -f 2 <<< $tmp_nvrecon)" #this won't work for v-pipe
      
      if [[ "$name_vir_ref" == "$name_vir_recon" ]]; #The viruses match, else skip
        then
      
        printf " REF --> $REF_FILE      FILE --> $file \n\n" 
  
        rm -rf out.report	 
        TIME=-1
        SNPS=-1
        IDEN=1
        NCSD=1
        NRC=1
        MEM=-1
        CPU_P=-1
        NR_SPECIES=-1
        DOES_ANALYSIS=-1
        DOES_CLASSIFICATION=-1

      
        fst_char=$(cat $file | head -c 1)
        if [[ -z "$fst_char" ]]; then
          printf "The result file is empty."    
        else
        #Convert it to unix, just in case
        dos2unix $file  
        
        # These may not be needed, but keeping as a percaution
        #gawk -i inplace '{ while(sub(/QuRe./,int(rand()*99999999999)+1)); print }' $file
        #gawk -i inplace '{ while(sub(/results/,int(rand()*99999999999)+1)); print }' $file
        #Upper case all characters
        cat $file | tr [:lower:] [:upper:] > tmp.txt
        mv tmp.txt $file

        #Run dnadiff and get results
        dnadiff $file $REF_FILE; #run dnadiff
        IDEN=`cat out.report | grep "AvgIdentity " | head -n 1 | awk '{ print $2;}'`;  #retrieve results
        ALBA=`cat out.report | grep "AlignedBases " | head -n 1 | awk '{ print $2;}'`;
        SNPS=`cat out.report | grep TotalSNPs | awk '{ print $2;}'`;
        TBASES=`cat out.report | grep "TotalBases" | awk '{ print $2;}'`;
        AUX="$(cut -d')' -f1 <<< "$ALBA")"
        PERALBA="$(cut -d'(' -f2 <<< "$AUX")"
        TALBA="$(cut -d'(' -f1 <<< "$ALBA")"    
        NRBASES=`cat out.report | grep "TotalBases" | awk '{ print $2;}'`;  
    
    
        tmp_f="$(echo $file | awk -F/ '{print $NF}')"
        file_wout_extension="$(cut -d'-' -f 1 <<< $tmp_f)"
        
        if [ "$file_wout_extension" == "v" ]; #dealing with V-pipe
          then
          file_wout_extension="v-pipe"
        fi
      
        TIME=`cat $D_PATH/$file_wout_extension-time.txt | grep "TIME" | awk '{ print $2;}'`;
        MEM=`cat $D_PATH/$file_wout_extension-time.txt | grep "MEM" | awk '{ print $2;}'`;
        CPU_P=`cat $D_PATH/$file_wout_extension-time.txt | grep "CPU_perc" | awk '{ print $2;}'`;

        k_val="$(cut -d'.' -f1 <<< $file)"
        k_val="$(echo $k_val | awk -F- '{print $NF}')"

        NAME_TOOL="$(cut -d'-' -f1 <<< $D_PATH/$file_wout_extension)"
        NAME_TOOL="$(cut -d'/' -f2 <<< $NAME_TOOL)"
      
        DOES_ANALYSIS="?"
        DOES_CLASSIFICATION="?"      

        for i in "${ANALYSIS[@]}" #check if the tool does metagenomic analysis
          do
          if [ "$i" == "$NAME_TOOL" ] ; then
            DOES_ANALYSIS="Yes"
            break
          fi 
        done
      
        if [ "$DOES_ANALYSIS" == "?" ] ; then
          for i in "${NO_ANALYSIS[@]}"
            do
            if [ "$i" == "$NAME_TOOL" ] ; then
              DOES_ANALYSIS="No"
              break
            fi 
          done
        fi
      
        for i in "${CLASSIFICATION[@]}" #check if the tool does metagenomic classification
          do
          if [ "$i" == "$NAME_TOOL" ] ; then
            DOES_CLASSIFICATION="Yes"
            break
          fi
        done
      
        if [ "$DOES_CLASSIFICATION" == "?" ] ; then
          for i in "${NO_CLASSIFICATION[@]}"
            do
            if [ "$i" == "$NAME_TOOL" ] ; then
              DOES_CLASSIFICATION="No"
              break
            fi 
          done
        fi
        
       # Get SeqKit statistics
      printf "$(seqkit stats $file | tail -1)"
      NR_SPECIES=$(seqkit stats $file  | tail -1 | sed 's/ \+ /\t/g' | sed 's/,//g' | cut -d'	' -f4)
      SUM_LEN=$(seqkit stats $file  | tail -1 | sed 's/ \+ /\t/g' | sed 's/,//g' | cut -d'	' -f5)
      MIN_LEN=$(seqkit stats $file  | tail -1 | sed 's/ \+ /\t/g' | sed 's/,//g' | cut -d'	' -f6)
      MAX_LEN=$(seqkit stats $file  | tail -1 | sed 's/ \+ /\t/g' | sed 's/,//g' | cut -d'	' -f8)
      AVG_LEN=$(seqkit stats $file  | tail -1 | sed 's/ \+ /\t/g' | sed 's/,//g' | cut -d'	' -f7)
      
      
      
      cat $file | tr -d 'N' | sed '/^$/d' > seqfile
      SUM_LEN_WOUT_N=$(seqkit stats seqfile | tail -1 | sed 's/ \+ /\t/g' | sed 's/,//g' | cut -d'	' -f5)
      MIN_LEN_WOUT_N=$(seqkit stats seqfile | tail -1 | sed 's/ \+ /\t/g' | sed 's/,//g' | cut -d'	' -f6)
      MAX_LEN_WOUT_N=$(seqkit stats seqfile | tail -1 | sed 's/ \+ /\t/g' | sed 's/,//g' | cut -d'	' -f8)
      AVG_LEN_WOUT_N=$(seqkit stats seqfile | tail -1 | sed 's/ \+ /\t/g' | sed 's/,//g' | cut -d'	' -f7)
      
      rm seqfile
     
      
      #printf "$NR_SPECIES $SUM_LEN  $MIN_LEN  $AVG_LEN  $MAX_LEN  \n\n"
   
      gto_fasta_rand_extra_chars < $file > tmp.fa
      gto_fasta_to_seq < tmp.fa > $file_wout_extension.seq
      gto_fasta_to_seq < $REF_FILE > $REF_FILE.seq
      
      
      #Compressing sequences C(X) or C(X,Y)
      GeCo3 -tm 1:1:0:1:0.9/0:0:0 -tm 7:10:0:1:0/0:0:0 -tm 16:100:1:10:0/3:10:0.9 -lr 0.03 -hs 64 $REF_FILE.seq 
      COMPRESSED_SIZE_WOUT_REF=$(ls -l $REF_FILE.seq.co | cut -d' ' -f5)
      rm $REF_FILE.seq.*
      #Conditional compression C(X|Y) [use reference and target]
      GeCo3 -rm 20:500:1:12:0.9/3:100:0.9 -rm 13:200:1:1:0.9/0:0:0 -tm 1:1:0:1:0.9/0:0:0 -tm 7:10:0:1:0/0:0:0 -tm 16:100:1:10:0/3:10:0.9 -lr 0.03 -hs 64 -r $file_wout_extension.seq $REF_FILE.seq
      COMPRESSED_SIZE_COND_COMPRESSION=$(ls -l $REF_FILE.seq.co | cut -d' ' -f5)  
      rm $REF_FILE.seq.*
      
      #Relative compression (only reference models) C(X||Y)
      GeCo3 -rm 20:500:1:12:0.9/3:100:0.9 -rm 13:200:1:1:0.9/0:0:0 -lr 0.03 -hs 64 -r $file_wout_extension.seq $REF_FILE.seq
      COMPRESSED_SIZE_W_REF_BYTES=$(ls -l $REF_FILE.seq.co | cut -d' ' -f5)   
      COMPRESSED_SIZE_W_REF=$(echo "$COMPRESSED_SIZE_W_REF_BYTES * 8.0" | bc -l )  
      rm $REF_FILE.seq.*            
      FILE_SIZE=$(ls -l $REF_FILE.seq | cut -d' ' -f5)
     
      #printf "NCSD -> $COMPRESSED_SIZE_COND_COMPRESSION " # . $COMPRESSED_SIZE_WOUT_REF"
      NCSD=$(echo $COMPRESSED_SIZE_COND_COMPRESSION \/ $COMPRESSED_SIZE_WOUT_REF |bc -l | xargs printf %.3f)
           
      AUX_MULT=$(echo "$FILE_SIZE * 2" | bc -l )
      if [ -z "$AUX_MULT" ]
        then
        printf "Skipping compression metrics, no reference.\n\n"
      else
        #printf "aux_mult   . $AUX_MULT\n\n"
        #printf "NRC -> $COMPRESSED_SIZE_W_REF . $AUX_MULT"
        NRC=$(echo $COMPRESSED_SIZE_W_REF \/ $AUX_MULT|bc -l | xargs printf %.3f)      
      fi
            
      IDEN=$(echo $IDEN |bc -l | xargs printf %.3f)
      MEM=$(echo $MEM \/ 1048576 |bc -l | xargs printf %.3f)
    
      #retrieve additional results dnadiff
      TOTAL_SEQS=`cat out.report | grep "TotalSeqs " | head -n 1 | awk '{ print $2;}'`;
    
      ALIGNED_SEQS=`cat out.report | grep "AlignedSeqs " | head -n 1 | awk '{ print $2;}'`;  
      AUX="$(cut -d')' -f1 <<< "$ALIGNED_SEQS")"
      ALIGNED_SEQS_PERC="$(cut -d'(' -f2 <<< "$AUX")"
      ALIGNED_SEQS_PERC="$(cut -d'%' -f1 <<< "$ALIGNED_SEQS_PERC")"
      ALIGNED_SEQS_NR="$(cut -d'(' -f1 <<< "$AUX")"
    
      ALIGNED_BASES=`cat out.report | grep "AlignedBases " | head -n 1 | awk '{ print $2;}'`;  
      AUX="$(cut -d')' -f1 <<< "$ALIGNED_BASES")"
      ALIGNED_BASES_PERC="$(cut -d'(' -f2 <<< "$AUX")"
      ALIGNED_BASES_PERC="$(cut -d'%' -f1 <<< "$ALIGNED_BASES_PERC")"
      ALIGNED_BASES_NR="$(cut -d'(' -f1 <<< "$AUX")"
    
      UNALIGNED_BASES=`cat out.report | grep "UnalignedBases " | head -n 1 | awk '{ print $2;}'`;  
      AUX="$(cut -d')' -f1 <<< "$UNALIGNED_BASES")"
      UNALIGNED_BASES_PERC="$(cut -d'(' -f2 <<< "$AUX")"
      UNALIGNED_BASES_PERC="$(cut -d'%' -f1 <<< "$UNALIGNED_BASES_PERC")"
      UNALIGNED_BASES_NR="$(cut -d'(' -f1 <<< "$AUX")"
    
      AVG_LEN=`cat out.report | grep "AvgLength " | head -n 1 | awk '{ print $2;}'`;    
      
      for tool in "${ORDER_TOOLS_CAP[@]}"
        do      
        tool_lower=$(echo "$tool" | tr '[:upper:]' '[:lower:]')
      
        if [ "$tool_lower" == "$NAME_TOOL" ] ; then
      
          NAME_TOOL=$tool
      
        fi 
      done

      #Write results to respective files
      CPU="$(cut -d'%' -f1 <<< "$CPU_P")"
      
      echo "$file	$name_vir_ref	$k_val	$SNPS	$IDEN	$NCSD	$NRC	$SUM_LEN	$MIN_LEN	$MAX_LEN	$AVG_LEN	$SUM_LEN_WOUT_N	$MIN_LEN_WOUT_N	$MAX_LEN_WOUT_N	$AVG_LEN_WOUT_N" >> Results/total_stats_k.tsv 


        fi
      fi

    
  conda activate base
  
else 
  printf "ERROR: At least one of the input directories does not exist. Exiting.\n\n"
fi 
#

