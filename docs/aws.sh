# 환경 변수 등록
export AWS_ACCESS_KEY_ID="AKIAIOSFODNN7EXAMPLE"
export AWS_SECRET_ACCESS_KEY="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
export AWS_DEFAULT_REGION="ap-northeast-2"

# 환경 변수 확인
echo $AWS_ACCESS_KEY_ID

# 버킷의 객체 목록 조회
aws s3 ls s3://bebc25

# 인증 정보 등록
aws configure

# 파일 업로드
aws s3 cp sample.txt s3://bebc25/uploads/sample.txt

# presigned url 생성(300초, 기본은 1시간, 최대 7일 까지 지정 가능)
aws s3 presign s3://bebc25/kitchen.png --expires-in 30

# 다운로드
aws s3 cp s3://bebc25/uploads/sample.txt ./downloaded_sample.txt

# 삭제
aws s3 rm s3://bebc25/uploads/sample.txt

# 조회
aws s3 ls s3://bebc25

# 인스턴스 목록 조회
aws ec2 describe-instances

# 인스턴스 중지
aws ec2 stop-instances --instance-ids i-0c8cc5e4a486cda04

# 인스턴스 시작
aws ec2 start-instances --instance-ids i-0c8cc5e4a486cda04

