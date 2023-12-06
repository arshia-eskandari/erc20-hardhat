// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Test, console2, StdStyle} from "forge-std/Test.sol";
import {ERC20} from "../contracts/ERC20.sol";

contract BaseSetup is Test, ERC20 {
    address internal testOwner = makeAddr("testOwner");
    address internal testFeeReceiver = makeAddr("testFeeReceiver");
    address internal alice;
    address internal bob;
    address internal charlie;

    constructor()
        ERC20(
            "name",
            "SYM",
            18,
            2,
            testFeeReceiver,
            1_000_000_000_000_000,
            testOwner
        )
    {}

    function setUp() public virtual {
        console2.log(StdStyle.green("Setting up state"));
        alice = makeAddr("alice");
        bob = makeAddr("bob");
        charlie = makeAddr("charlie");
        deal(address(this), alice, 300e18); // _mint(alice, 300e18);
        deal(address(this), bob, 50e18); // _mint(bob, 50e18);
    }
}

contract ERC20TransferTest is BaseSetup {
    function testTransferTokensCorrectly() public {
        vm.prank(alice); // The following line works as if alice call it
        bool success = this.transfer(bob, 100e18);
        assertTrue(success);
        // The following 3 lines are calling the getter function
        // due to the this keywordfor the public state balanceOf
        // assertEq(this.balanceOf(alice), 200e18);
        // assertEq(this.balanceOf(bob), 98e18);
        // assertEq(this.balanceOf(feeReceiver), 2e18);
        // The following 3 lines use the public state balanceOf directly
        assertEqDecimal(balanceOf[alice], 200e18, 18);
        assertEqDecimal(balanceOf[bob], 148e18, 18);
        assertEqDecimal(balanceOf[feeReceiver], 2e18, 18);
    }

    function testCannotTransferMoreThanBalance() public {
        vm.prank(alice);
        vm.expectRevert(); // Expect a revert on the following line (can pass a message to it)
        this.transfer(bob, 400e18);
    }

    function testEmitsTransferEvent() public {
        vm.expectEmit(true, true, true, true);
        emit Transfer(alice, bob, 98e18);
        emit Transfer(alice, bob, 2e18);

        vm.prank(alice); // The following line works as if alice call it
        this.transfer(bob, 100e18);
    }
}

contract ERC20TransferFromTest is BaseSetup {
    function testTransferFromTokensCorrectly() public {
        vm.prank(alice);
        this.approve(bob, 10e18);
        vm.prank(bob);
        bool success = this.transferFrom(alice, charlie, 7e18);
        assertTrue(success);
        assertEqDecimal(balanceOf[alice], 293e18, 18);
        assertEqDecimal(balanceOf[bob], 50e18, 18);
        assertEqDecimal(balanceOf[charlie], 6.86e18, 18);
        assertEqDecimal(balanceOf[feeReceiver], 1.4e17, 18);
    }
}
