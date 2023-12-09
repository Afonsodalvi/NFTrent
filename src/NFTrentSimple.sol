// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "solmate/utils/ReentrancyGuard.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";
import "erc721a/contracts/ERC721A.sol";
import {ERC4907A} from "erc721a/contracts/extensions/ERC4907A.sol";

    error MintPriceNotPaid();
    error NonExistentTokenURI();
    error WithdrawTransfer();
    error notApprovedUse();


contract NFTrent is ERC4907A, Ownable, ReentrancyGuard {

    using Strings for uint256;//usar a library quando indicada para transformar o numero em string.
    string public baseURI;//variável do metadado salva no armazenamento do contrato globalmente
    uint256 public TOTAL_SUPPLY;//variável do total emitido

    //price collection
    uint256 public price;//variável do preço

    //setando no contrutor os parametros para atualizar as informações 
    //das variáveis do nosso contrato e o do NFT padrão ERC721A
        constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseURi,
        uint256 totalsupply,
        uint256 _price
    ) ERC721A(_name, _symbol) Ownable(msg.sender) {
        baseURI = _baseURi;
        TOTAL_SUPPLY = totalsupply;
        price = _price;
    }

//funções de mint para comprar seu NFT com o valor setado na construção em `price`:

    function mint() external payable nonReentrant returns (uint256){
        // `_mint`'s second argument now takes in a `quantity`, not a `tokenId`
        if (msg.value < price) {
            revert MintPriceNotPaid();
        }
        uint256 newTokenId = _nextTokenId() + 1;
        require(newTokenId <= TOTAL_SUPPLY, "Max supply reached");
        _safeMint(msg.sender, 1);
        return newTokenId;
    }

    //função principal que deve ser interagida pelo owner no NFT:

    function setUser(uint256 tokenId, address user, uint64 expires) public override(ERC4907A) {
        super.setUser(tokenId, user, expires); //usa a funçao de setar o usuário e 
        //o tempo que ele poderá usar a função de benefício abaixo.

    }

//obs. a função abaixo é meramente educacional 
//função de usar beneficio referente ao tokenId onde o 
//usuário poderá pegar o valor do saldo do contrato dividio por 2:
    function useBenefiti(uint256 _tokenId) public {
        if(userOf(_tokenId) != msg.sender) revert notApprovedUse();
        uint256 balance = address(this).balance /2;
        (bool transferTx, ) = address(msg.sender).call{ value: balance }("");
        if (!transferTx) {
            revert WithdrawTransfer();
        }
    }

//setar o novo preço caso o dono do contrato queira:
    function setPrice(uint256 _price) external onlyOwner {
        price = _price;
    }

//função que subistitui as do contrato de ERC721A referente ao retorno do metadado
    function tokenURI(uint256 tokenId) public view virtual override(ERC721A,IERC721A) returns (string memory) {
        if (ownerOf(tokenId) == address(0)) {
            revert NonExistentTokenURI();
        }
        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, tokenId.toString()))
                : "";
    }

//função de saque do saldo do contrato feita pelo dono para a conta setada:
    function withdrawPayments(address payee) external onlyOwner {
        uint256 balance = address(this).balance;
        (bool transferTx, ) = payee.call{ value: balance }("");
        if (!transferTx) {
            revert WithdrawTransfer();
        }
    }


}
