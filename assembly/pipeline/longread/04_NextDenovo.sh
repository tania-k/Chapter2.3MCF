#!/usr/bin/bash -l
#SBATCH -p batch -N 1 -n 64 --time=3-00:15:00 --mem 128gb --out logs/NextDenovo.%a.log -a 1-12

module load NextDenovo

IFS=,
SAMPLES=nanopore_samples.csv
OUTDIR=asm/NextDenovo
INDIR=input/nanopore
TEMPLATECONFIG=lib/NextDenovo.cfg

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
    mkdir -p $OUTDIR/$STRAIN
    realpath $INDIR/$NANOPORE > $OUTDIR/$STRAIN/reads.fofn
    cp $TEMPLATECONFIG $OUTDIR/$STRAIN/NextDenovo.cfg
    pushd $OUTDIR/$STRAIN
    nextDenovo NextDenovo.cfg
    popd
done
