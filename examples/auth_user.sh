 curl \
  -XPOST \
  localhost:4000/api/auth/identity/callback \
  -H 'content-type: application/json' \
  -d @- << EOF
   {"user": {"username": "$1", "password": "$2"}}
EOF
