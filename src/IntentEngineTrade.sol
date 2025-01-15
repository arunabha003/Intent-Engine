// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import { IntentEngineRegistry } from "./IntentEngineRegistry.sol";
import { IUniswap } from "./IUniswap.sol";

contract IntentEngine is IntentEngineRegistry{
    error InvalidSyntax();
    error InvalidCharacter();

    struct StringPart {
        uint256 start;
        uint256 end;
    }

    function commandToTrade(
        string calldata intent
    )
        external pure
        returns (string memory pair, uint256 amount, string memory protocol)
    {
        address to = msg.sender;
        bytes memory normalized = _lowercase(bytes(intent));
        StringPart[] memory parts = _split(normalized, " ");

        if (parts.length != 3) revert InvalidSyntax(); // Expect "pair amount protocol"

        bytes memory pairBytes = _getPart(normalized, parts[0]);
        bytes memory amountBytes = _extractAmount(normalized);
        bytes memory protocolBytes = _getPart(normalized, parts[2]);

        pair = string(pairBytes);   
        amount = _toUint(amountBytes, 18, true);
        protocol = string(protocolBytes);

        // will fetch pair from registry
        //input pair if protocol = uniswap then swap on uniswap

        //-----------path define krna hoga in array bc-------------------

        if(protocol=="uniswap"){
            //call uniswap function
            IUniswap(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D).swapExactTokensForTokens(amount, 0, , to, deadline);

        }

        return (pair, amount, protocol);
    }

    function _extractAmount(
        bytes memory normalizedIntent
    ) internal pure returns (bytes memory amount) {
        StringPart[] memory parts = _split(normalizedIntent, " ");
        return _getPart(normalizedIntent, parts[1]); // Extract the "amount" part
    }


    function _split(
        bytes memory base,
        string memory delimiter
    ) internal pure returns (StringPart[] memory parts) {
        require(
            bytes(delimiter).length == 1,
            "Delimiter must be one character"
        );
        bytes1 del = bytes(delimiter)[0];
        uint256 len = base.length;
        uint256 count;

        unchecked {
            for (uint256 i = 0; i < len; ++i) {
                if (base[i] == del) count++;
            }

            parts = new StringPart[](count + 1);
            uint256 partIndex;
            uint256 start;

            for (uint256 i; i <= len; ++i) {
                if (i == len || base[i] == del) {
                    parts[partIndex++] = StringPart(start, i);
                    start = i + 1;
                }
            }
        }
    }

    function _getPart(
        bytes memory base,
        StringPart memory part
    ) internal pure returns (bytes memory result) {
        result = new bytes(part.end - part.start);
        for (uint256 i = 0; i < result.length; ++i) {
            result[i] = base[part.start + i];
        }
    }

    function _lowercase(
        bytes memory subject
    ) internal pure returns (bytes memory result) {
        result = new bytes(subject.length);
        for (uint256 i = 0; i < subject.length; ++i) {
            bytes1 b = subject[i];
            result[i] = (b >= 0x41 && b <= 0x5A) ? bytes1(uint8(b) + 32) : b;
        }
    }

    function _toUint(
        bytes memory s,
        uint256 decimals,
        bool scale
    ) internal pure returns (uint256 result) {
        unchecked {
            uint256 len = s.length;
            bool hasDecimal;
            uint256 decimalPlaces;

            for (uint256 i; i < len; ++i) {
                bytes1 c = s[i];
                if (c >= 0x30 && c <= 0x39) {
                    // '0' to '9'
                    result = result * 10 + (uint256(uint8(c)) - 48);
                    if (hasDecimal) {
                        if (++decimalPlaces > decimals) break;
                    }
                } else if (c == 0x2E && !hasDecimal) {
                    // '.'
                    hasDecimal = true;
                } else {
                    revert InvalidCharacter();
                }
            }

            if (scale) {
                if (!hasDecimal) result *= 10 ** decimals;
                else if (decimalPlaces < decimals)
                    result *= 10 ** (decimals - decimalPlaces);
            }
        }
    }

    receive() external payable {}

    fallback() external payable {}
}
