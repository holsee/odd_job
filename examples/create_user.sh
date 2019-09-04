curl \
  -XPOST \
  -v \
  localhost:4000/api/users \
  -H 'content-type: application/json' \
  -H "authorization: Bearer $3" \
  -d @- << EOF
   {"user": {"username": "$1", "password": "$2"}}
EOF
