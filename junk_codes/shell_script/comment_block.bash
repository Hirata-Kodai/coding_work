echo "Before comment out"
: << 'COMMENT'
echo "I'm in comment out block."
COMMENT
echo "After comment out"
