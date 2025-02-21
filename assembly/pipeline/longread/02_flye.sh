#!/usr/bin/bash -l
#SBATCH -p intel -N 1 -n 64 --time=3-00:15:00 --mem 128gb --out logs/flye_scaf.%a.log -a 1-12

module load Flye

IFS=,
SAMPLES=nanopore_samples.csv
OUTDIR=asm/flye
INDIR=input/nanopore
mkdir -p $OUTDIR

CPUS=$SLURM_CPUS_ON_NODE
if [ -z $CPUS ]; then
 CPUS=1
fi

N=${SLURM_ARRAY_TASK_ID}
if [ -z $N ]; then
    N=$1
    if [ -z $N ]; then
	echo "no value for SLURM ARRAY - specify with -a or cmdline"
    fi
fi

sed -n ${N}p $SAMPLES | while read STRAIN NANOPORE
do
    flye --genome-size 45m -t $CPUS -o $OUTDIR/$STRAIN -i 5 --nano-hq $INDIR/$NANOPORE --scaffold

done
