readarray -t eCollection < <(cut -d, -f1 snapshot.csv) # read first column of account names from snapshot file

echo "${eCollection[0]}"

readarray -t bCollection < <(cut -d, -f2 snapshot.csv) # read second column of EOS Balance from snapshot file
echo "${bCollection[0]}"

c=1 # counter for while loop

i=1 # index for Arrays, starting from 1 to skip 0 index in order to skip the default b account of snapshot

while (( $c <= 163926))
do

bCollection[i]=$(echo "${bCollection[i]} * 1.0000" | bc)

cleos -u http://api.cypherglass.com:8888/ push action eosatidiumio transfer '["eosatidiumio","'${eCollection[i]}'","'${bCollection[i]}' ATD",""]' -p eosatidiumio

# verify airdop by checking ATD balance :
ATD_Balance=$(cleos -u http://api.cypherglass.com:8888/ get table eosatidiumio ${eCollection[i]} accounts | grep ATD | grep -Eo '[0-9]+\.[0-9]+') 


echo "${eCollection[i]} has ${ATD_Balance} ATD tokens and ${bCollection[i]} EOS tokens "

if [ "$ATD_Balance" != "${bCollection[i]}" ]; then
# if any account could not get ATD tokens equal to their EOS balance, those accounts along with their EOS balance would be stored in a csv file for next airdrop
echo "${eCollection[i]},${bCollection[i]},$ATD_Balance">>error.csv # first column: account_name, 2nd column: EOS balance, 3rd column: ATD balance (if any)
fi

c=$((c+1))
i=$((i+1))
done

