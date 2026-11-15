# Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a Hardhat Ignition module that deploys that contract.

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat ignition deploy ./ignition/modules/Lock.ts
```

## vscode(WSL)가 .vy 파일에서 vyper를 찾지 못하는 문제
### 사전 설정
1. 가상환경 설치 및 활성화
```bash
python3 -m venv .venv

source .venv/bin/activate
```

2. vyper 설치
```bash
pip install vyper==0.3.10
```

### vscode로 열 때
1. 프로젝트 루트로 이동
```bash
cd <프로젝트 루트>
```

2. 가상환경 활성화
```bash
source .venv/bin/activate
```

3. vscode 실행
```bash
code .
```
